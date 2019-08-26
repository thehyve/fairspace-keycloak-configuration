#!/bin/bash
#
# This script sets up keycloak for a single hyperspace
#
# Required arguments to this script are:
#   url:      Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username: Username of the administrative user to login
#   realm:    Name of the realm to create
#   redirect-url-file:   Name of the file that contains all the redirect urls for the workspace.
#                        Should at least contain the pluto url, after-logout url and jupyterhub url
#   additional_users:   If set to true, a number of test users will be added to keycloak for testing
#                       or demo purposes
#
# The password is expected to be set as environment variable KEYCLOAK_PASSWORD
# The organisation admin username can be set as environment variable ORGANISATION_ADMIN_USERNAME. It defaults to organisation-admin
# The organisation admin password is expected to be set as environment variable ORGANISATION_ADMIN_PASSWORD
# The testuser password is expected to be set as environment variable TESTUSER_PASSWORD
# The client secret is expected to be set as environment variable CLIENT_SECRET
# The client id can be set as environment variable CLIENT_ID. It defaults to hyperspace
#
echo "Setting up Hyperspace in keycloak ..."
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
USER="$2"
REALM="$3"
REDIRECT_URL_FILE="$4"
ADDITIONAL_TEST_USERS=${5:-true}

ORGANISATION_ADMIN_USERNAME="${ORGANISATION_ADMIN_USERNAME:-organisation-admin}"
CLIENT_ID="${CLIENT_ID:-hyperspace}"

# Wait for the server to be online. This may take a while, as the webserver waits for postgres
# If the server will not be up after 5 minutes, the script will die and helm will start a new container
./wait-for-server-to-respond.sh "$SERVER" || exit 1

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm master --server "$SERVER" --user "$USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Add a realm and a hyperspace client for it
echo "Creating realm and client ..."
sed -e "s/\${REALM}/$REALM/g" ./hyperspace-config/hyperspace-realm.json | kcadm.sh create realms -f -

# Retrieve default settings first
REALM_MANAGEMENT_UUID=$(./functions/get-realm-management-uuid.sh "$REALM")
export REALM_MANAGEMENT_UUID

echo "Configuring private client ..."
./functions/add-private-client.sh "$REALM" "$CLIENT_ID" "$CLIENT_SECRET" "$REDIRECT_URL_FILE"

# Enable user management permissions on this realm
echo "Enabling user management permissions ..."
./functions/enable-user-management-permissions.sh "$REALM"
echo "Creating workspace coordinator role ..."
./functions/add-role.sh "$REALM" "workspace-coordinator" "User is a workspace coordinator"
echo "Creating workspace coordinator role policy ..."
./functions/add-role-policy.sh "$REALM" "workspace-coordinator" "workspace-coordinator"

# Update the existing permission, as adding new permissions does not actually
# apply the permission
echo "Updating permissions ..."
./functions/update-permission.sh "$REALM" "manage-group-membership.permission.users" "workspace-coordinator"

# Initialize a role and group for organisation admins
echo "Creating role and group for organisation admins..."
ORGANISATION_ADMINS_GROUP_ID=$(./functions/create-role-and-group.sh "$REALM" "admin"  "organisation" "User can create workspaces")

echo "Adding realm role organisation-admin ..."
./functions/add-realm-role-to-group.sh "$REALM" "$ORGANISATION_ADMINS_GROUP_ID" "admin-organisation"
echo "Adding client role to group ..."
./functions/add-client-role-to-group.sh "$REALM" "$ORGANISATION_ADMINS_GROUP_ID" "realm-management" "view-users"
echo "Associated group and role for organisation admins."

# Create a first organisation admin specified in parameters
echo "Creating organisation admin user ..."
./functions/create-user.sh "$REALM" "$ORGANISATION_ADMIN_USERNAME" "First" "Organisation Admin" "$ORGANISATION_ADMIN_PASSWORD"
ORGANISATION_ADMIN_ID=$(./functions/get-user-id.sh "$REALM" "$ORGANISATION_ADMIN_USERNAME")
echo "Adding coordinator user to coordinator group ..."
./functions/add-user-to-group.sh "$REALM" "$ORGANISATION_ADMIN_ID" "$ORGANISATION_ADMINS_GROUP_ID"

# Create a number of additional testusers
if [ "$ADDITIONAL_TEST_USERS" == "true" ]; then
    echo "--- Creating additional test users ... ---"
    ./functions/add-test-users.sh "$REALM"
fi

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak Hyperspace script finished."
exit 0
