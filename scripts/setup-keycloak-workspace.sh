#!/bin/bash
#
# This script sets up keycloak for a single workspace
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   realm:        Name of the realm to perform actions in
#   workspace:    Name of the workspace to create
#   redirect-url-file:   Name of the file that contains all the redirect urls for the workspace.
#                        Should at least contain the pluto url, after-logout url and jupyterhub url
#   test-users:          Whether to add additional test users (e.g. for ci)
#
# By default the keycloak user logs in to the master realm. However, the script can also
# be run by a realm-admin of the realm that must be configured. You can specify the LOGIN_REALM variable
# to point to the right realm to login. Please note that the user needs the realm-management/realm-admin
# to configure the workspace.
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
# The client secret is expected to be set as environment variable CLIENT_SECRET
# The testuser username is expected to be set as environment variable TESTUSER_USERNAME.
#    If not set, if defaults to 'test-$WORKSPACE_NAME'
# The testuser password is expected to be set as environment variable TESTUSER_PASSWORD
# The coordinator username is expected to be set as environment variable COORDINATOR_USERNAME.
#    If not set, if defaults to 'coordinator-$WORKSPACE_NAME'
# The coordinator password is expected to be set as environment variable COORDINATOR_PASSWORD
#
echo "Setting up Workspace in keycloak ..."
echo "Starting at " $(date -Iseconds)
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
KEYCLOAK_USER="$2"
REALM="$3"
WORKSPACE_NAME="$4"
REDIRECT_URL_FILE="$5"
ADDITIONAL_TEST_USERS=${6:-true}

# See if login realm has been provided
LOGIN_REALM=${LOGIN_REALM:-master}

# Parameters for first user
TESTUSER_USERNAME="${TESTUSER_USERNAME:-test-$WORKSPACE_NAME}"
TESTUSER_FIRSTNAME="First"
TESTUSER_LASTNAME="User"

# Parameters for first coordinator
COORDINATOR_USERNAME="${COORDINATOR_USERNAME:-coordinator-$WORKSPACE_NAME}"
COORDINATOR_FIRSTNAME="First"
COORDINATOR_LASTNAME="Coordinator"

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm $LOGIN_REALM --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Retrieve default settings first
export REALM_MANAGEMENT_UUID=$(./functions/get-realm-management-uuid.sh "$REALM")

# Initialize a role and group for normal users
echo "Creating role for regular users ..."
./functions/add-role.sh "$REALM" "user-${WORKSPACE_NAME}" "User can login to workspace ${WORKSPACE_NAME}"
echo "Creating group for regular users ..."
./functions/add-group.sh "$REALM" "${WORKSPACE_NAME}-users"
USERS_GROUP_ID=$(./functions/get-group-id.sh "$REALM" "${WORKSPACE_NAME}-users")

echo "Adding realm role for regular users to group ..."
./functions/add-realm-role-to-group.sh "$REALM" "$USERS_GROUP_ID" "user-${WORKSPACE_NAME}"
echo "Adding client role for regular users to group ..."
./functions/add-client-role-to-group.sh "$REALM" "$USERS_GROUP_ID" "realm-management" "view-users"
echo "Associated group and role for users."

# Initialize a role and group for coordinators
echo "Creating role for coordinators ..."
./functions/add-role.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "User can coordinate workspace ${WORKSPACE_NAME}"
echo "Creating group for coordinators ..."
./functions/add-group.sh "$REALM" "${WORKSPACE_NAME}-coordinators"
COORDINATORS_GROUP_ID=$(./functions/get-group-id.sh "$REALM" "${WORKSPACE_NAME}-coordinators")
echo "Adding realm role workspace-coordinator ..."
./functions/add-realm-role-to-group.sh "$REALM" "$COORDINATORS_GROUP_ID" "workspace-coordinator"
echo "Adding realm role coordinator-${WORKSPACE_NAME} ...  "
./functions/add-realm-role-to-group.sh "$REALM" "$COORDINATORS_GROUP_ID" "coordinator-${WORKSPACE_NAME}"
echo "Adding client role to group ..."
./functions/add-client-role-to-group.sh "$REALM" "$COORDINATORS_GROUP_ID" "realm-management" "view-users"
echo "Associated group and role for coordinators."

# Ensure that the coordinators can manage members of the users group
echo "Creating coordinator role policy ..."
./functions/add-role-policy.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "coordinator-${WORKSPACE_NAME}"
echo "Enabling coordinator role policy ..."
./functions/enable-permissions-for-group.sh "$REALM" "$USERS_GROUP_ID"

# Update permission, as adding a new one does not work as expected
echo "Updating permissions coordinator role ..."
./functions/update-permission.sh "$REALM" "manage.membership.permission.group.$USERS_GROUP_ID" "workspace-coordinator"
echo "Allowed coordinators to manage members of users group"

# Create the testuser specified in parameters
echo "Creating test user ..."
./functions/create-user.sh "$REALM" "$TESTUSER_USERNAME" "$TESTUSER_FIRSTNAME" "$TESTUSER_LASTNAME" "$TESTUSER_PASSWORD"
USER_ID=$(./functions/get-user-id.sh "$REALM" "$TESTUSER_USERNAME")
echo "Adding test user ($USER_ID) to group ..."
./functions/add-user-to-group.sh "$REALM" "$USER_ID" "$USERS_GROUP_ID"

# Create a first coordinator specified in parameters
echo "Creating coordinator user ..."
./functions/create-user.sh "$REALM" "$COORDINATOR_USERNAME" "$COORDINATOR_FIRSTNAME" "$COORDINATOR_LASTNAME" "$COORDINATOR_PASSWORD"
COORDINATOR_ID=$(./functions/get-user-id.sh "$REALM" "$COORDINATOR_USERNAME")
echo "Adding coordinator user to user group ..."
./functions/add-user-to-group.sh "$REALM" "$COORDINATOR_ID" "$USERS_GROUP_ID"
echo "Adding coordinator user to coordinator group ..."
./functions/add-user-to-group.sh "$REALM" "$COORDINATOR_ID" "$COORDINATORS_GROUP_ID"

# Create a number of additional testusers
if [ "$ADDITIONAL_TEST_USERS" == "true" ]; then
    echo "Creating additional test users ..."
    ./functions/add-test-users.sh "$REALM" "$WORKSPACE_NAME"
fi

# Setup public and private clients for the current realm
echo "Configuring private client ..."
./functions/add-private-client.sh "$REALM" "${WORKSPACE_NAME}-pluto" "$CLIENT_SECRET" "$REDIRECT_URL_FILE"
echo "Configuring public client ..."
./functions/add-public-client.sh "$REALM" "${WORKSPACE_NAME}-public" "$REDIRECT_URL_FILE"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak Workspace script finished."
echo "Finihed at " $(date -Iseconds)
exit 0
