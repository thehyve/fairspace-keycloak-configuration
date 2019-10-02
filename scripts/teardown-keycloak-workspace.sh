#!/bin/bash
#
# This script removes keycloak configuration for a single workspace
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   realm:        Name of the realm to perform actions in
#   workspace:    Name of the workspace to create
#
# By default the keycloak user logs in to the master realm. However, the script can also
# be run by a realm-admin of the realm that must be configured. You can specify the LOGIN_REALM variable
# to point to the right realm to login. Please note that the user needs the realm-management/realm-admin
# to configure the workspace.
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
#
echo "Teardown workspace in keycloak ..."
echo "Starting at $(date -Iseconds)"
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
KEYCLOAK_USER="$2"
REALM="$3"
WORKSPACE_NAME="$4"

# See if login realm has been provided
LOGIN_REALM=${LOGIN_REALM:-master}

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm "$LOGIN_REALM" --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Retrieve default settings first
REALM_MANAGEMENT_UUID=$(./functions/get-realm-management-uuid.sh "$REALM")
export REALM_MANAGEMENT_UUID

echo "--- Removing roles ---"
./functions/delete-role.sh "$REALM" "user-${WORKSPACE_NAME}"
./functions/delete-role.sh "$REALM" "coordinator-${WORKSPACE_NAME}"
./functions/delete-role.sh "$REALM" "datasteward-${WORKSPACE_NAME}"
./functions/delete-role.sh "$REALM" "sparqluser-${WORKSPACE_NAME}"

echo "--- Removing clients ---"
./functions/delete-client.sh "$REALM" "${WORKSPACE_NAME}-pluto"
./functions/delete-client.sh "$REALM" "${WORKSPACE_NAME}-public"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak Workspace teardown finished."
echo "Finished at $(date -Iseconds)"
exit 0
