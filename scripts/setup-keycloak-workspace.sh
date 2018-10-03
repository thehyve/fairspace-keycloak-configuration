#!/bin/bash
#
# This script sets up keycloak for a single workspace
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   realm:        Name of the realm to perform actions in
#   workspace:    Name of the workspace to create
#   pluto-url:    Url of the pluto instance in the workspace. For example https://pluto.workspace.fairdev.app
#   after-logout-url:    Url the user is redirected to after logging off. For example https://pluto.workspace.fairdev.app
#   test-users:          Whether to add additional test users (e.g. for ci)
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
# The testuser username is expected to be set as environment variable TESTUSER_USERNAME.
#    If not set, if defaults to 'test-$WORKSPACE_NAME'
# The testuser password is expected to be set as environment variable TESTUSER_PASSWORD
# The client secret is expected to be set as environment variable CLIENT_SECRET
#
echo "Setting up workspace in keycloak"
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
KEYCLOAK_USER="$2"
REALM="$3"
WORKSPACE_NAME="$4"
PLUTO_URL="$5"
AFTER_LOGOUT_URL="$6"
TEST_USERS=${7:true}

TESTUSER_USERNAME="${TESTUSER_USERNAME:-test-$WORKSPACE_NAME}"
TESTUSER_FIRSTNAME="John"
TESTUSER_LASTNAME="Snow"

# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Initialize a role and group
./functions/add-role.sh "$REALM" "user-${WORKSPACE_NAME}" "User can login to workspace ${WORKSPACE_NAME}"
./functions/add-group.sh "$REALM" "${WORKSPACE_NAME}-users"

# Add the roles (logging in to the workspace and viewing users) to the group
./functions/add-realm-role-to-group.sh "$REALM" "$WORKSPACE_NAME-users" "user-$WORKSPACE_NAME"
./functions/add-client-role-to-group.sh "$REALM" "$WORKSPACE_NAME-users" "realm-management" "view-users"

# Create the testuser specified in parameters
./functions/create-user.sh "$REALM" "$TESTUSER_USERNAME" "$TESTUSER_FIRSTNAME" "$TESTUSER_LASTNAME" "$TESTUSER_PASSWORD"
./functions/add-user-to-group.sh "$REALM" "$TESTUSER_USERNAME" "${WORKSPACE_NAME}-users"

# Create a number of additional testusers
if [ "$TEST_USERS" -eq "true" ]; then
    ./functions/add-test-users.sh "$REALM" "$WORKSPACE_NAME"
fi

# Setup public and private clients for the current realm
./functions/add-private-client.sh "$REALM" "${WORKSPACE_NAME}-pluto" "$CLIENT_SECRET" "$PLUTO_URL" "$AFTER_LOGOUT_URL"
./functions/add-public-client.sh "$REALM" "${WORKSPACE_NAME}-public" "$PLUTO_URL" "$AFTER_LOGOUT_URL"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
exit 0
