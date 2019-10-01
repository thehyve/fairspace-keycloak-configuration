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
#
# By default the keycloak user logs in to the master realm. However, the script can also
# be run by a realm-admin of the realm that must be configured. You can specify the LOGIN_REALM variable
# to point to the right realm to login. Please note that the user needs the realm-management/realm-admin
# to configure the workspace.
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
# The client secret is expected to be set as environment variable CLIENT_SECRET
#
echo "Setting up Workspace in keycloak ..."
echo "Starting at $(date -Iseconds)"
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
KEYCLOAK_USER="$2"
REALM="$3"
WORKSPACE_NAME="$4"
REDIRECT_URL_FILE="$5"

# See if login realm has been provided
LOGIN_REALM=${LOGIN_REALM:-master}

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm "$LOGIN_REALM" --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Retrieve default settings first
REALM_MANAGEMENT_UUID=$(./functions/get-realm-management-uuid.sh "$REALM")
export REALM_MANAGEMENT_UUID

echo "--- Initializing roles ---"

# Initialize roles
./functions/add-role.sh "$REALM" "user-${WORKSPACE_NAME}" "User can login to workspace ${WORKSPACE_NAME}"
./functions/add-role.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "User can coordinate workspace ${WORKSPACE_NAME}"
./functions/add-role.sh "$REALM" "datasteward-${WORKSPACE_NAME}" "User is data steward in workspace ${WORKSPACE_NAME}"
./functions/add-role.sh "$REALM" "sparqluser-${WORKSPACE_NAME}" "User can execute sparql queries in workspace ${WORKSPACE_NAME}"

USER_ROLE_ID=$(./functions/get-role-id.sh "$REALM" "user-${WORKSPACE_NAME}")
COORDINATOR_ROLE_ID=$(./functions/get-role-id.sh "$REALM" "coordinator-${WORKSPACE_NAME}")
DATASTEWARD_ROLE_ID=$(./functions/get-role-id.sh "$REALM" "datasteward-${WORKSPACE_NAME}")
SPARQLUSER_ROLE_ID=$(./functions/get-role-id.sh "$REALM" "sparqluser-${WORKSPACE_NAME}")

# Make sure the roles map to the right permissions
echo "--- Creating policies for roles ---"
./functions/add-role-policy.sh "$REALM" "user-${WORKSPACE_NAME}" "user-${WORKSPACE_NAME}"
./functions/add-role-policy.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "coordinator-${WORKSPACE_NAME}"

# Ensure that the coordinators can manage members of the users group
echo "--- Enabling permissions for roles ---"
./functions/enable-permissions-for-role.sh "$REALM" "$USER_ROLE_ID"
./functions/enable-permissions-for-role.sh "$REALM" "$COORDINATOR_ROLE_ID"
./functions/enable-permissions-for-role.sh "$REALM" "$DATASTEWARD_ROLE_ID"
./functions/enable-permissions-for-role.sh "$REALM" "$SPARQLUSER_ROLE_ID"

echo "--- Ensuring the right permissions for users and coordinators ---"
functions/add-policy-for-permission.sh "$REALM" "view.permission.users" "user-${WORKSPACE_NAME}"
functions/add-policy-for-permission.sh "$REALM" "map-roles.permission.users" "coordinator-${WORKSPACE_NAME}"

functions/add-policy-for-permission.sh "$REALM" "map-role.permission.$USER_ROLE_ID" "coordinator-${WORKSPACE_NAME}"
functions/add-policy-for-permission.sh "$REALM" "map-role.permission.$DATASTEWARD_ROLE_ID" "coordinator-${WORKSPACE_NAME}"
functions/add-policy-for-permission.sh "$REALM" "map-role.permission.$SPARQLUSER_ROLE_ID" "coordinator-${WORKSPACE_NAME}"

./functions/add-composite-role.sh "$REALM" "$COORDINATOR_ROLE_ID" "realm-management" "query-clients"
./functions/add-composite-role.sh "$REALM" "$COORDINATOR_ROLE_ID" "realm-management" "view-realm"

echo "--- Ensure the organisation admin to be able to login to and coordinate the workspace ---"
ORGANISATION_ADMIN_ID=$(./functions/get-role-id.sh "$REALM" "organisation-admin")

./functions/add-composite-realm-role.sh "$REALM" "$ORGANISATION_ADMIN_ID" "user-${WORKSPACE_NAME}"
./functions/add-composite-realm-role.sh "$REALM" "$ORGANISATION_ADMIN_ID" "coordinator-${WORKSPACE_NAME}"

echo "--- Configuring clients ---"

# Setup public and private clients for the current realm
echo "Configuring private client ..."
./functions/add-private-client.sh "$REALM" "${WORKSPACE_NAME}-pluto" "$CLIENT_SECRET" "$REDIRECT_URL_FILE"
echo "Configuring public client ..."
./functions/add-public-client.sh "$REALM" "${WORKSPACE_NAME}-public" "$REDIRECT_URL_FILE"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak Workspace script finished."
echo "Finished at $(date -Iseconds)"
exit 0
