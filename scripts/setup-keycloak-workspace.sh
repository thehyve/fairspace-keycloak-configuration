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
# The client secret is expected to be set as environment variable CLIENT_SECRET
# The testuser username is expected to be set as environment variable TESTUSER_USERNAME.
#    If not set, if defaults to 'test-$WORKSPACE_NAME'
# The testuser password is expected to be set as environment variable TESTUSER_PASSWORD
# The coordinator username is expected to be set as environment variable COORDINATOR_USERNAME.
#    If not set, if defaults to 'coordinator-$WORKSPACE_NAME'
# The coordinator password is expected to be set as environment variable COORDINATOR_PASSWORD
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
ADDITIONAL_TEST_USERS=${7:-true}

# Parameters for first user
TESTUSER_USERNAME="${TESTUSER_USERNAME:-test-$WORKSPACE_NAME}"
TESTUSER_FIRSTNAME="First"
TESTUSER_LASTNAME="User"

# Parameters for first coordinator
COORDINATOR_USERNAME="${COORDINATOR_USERNAME:-coordinator-$WORKSPACE_NAME}"
COORDINATOR_FIRSTNAME="First"
COORDINATOR_LASTNAME="Coordinator"

# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Initialize a role and group for normal users
./functions/add-role.sh "$REALM" "user-${WORKSPACE_NAME}" "User can login to workspace ${WORKSPACE_NAME}"
./functions/add-group.sh "$REALM" "${WORKSPACE_NAME}-users"
./functions/add-realm-role-to-group.sh "$REALM" "${WORKSPACE_NAME}-users" "user-${WORKSPACE_NAME}"
./functions/add-client-role-to-group.sh "$REALM" "${WORKSPACE_NAME}-users" "realm-management" "view-users"
echo "Associated group and role for users"

# Initialize a role and group for coordinators
./functions/add-role.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "User can coordinate workspace ${WORKSPACE_NAME}"
./functions/add-group.sh "$REALM" "${WORKSPACE_NAME}-coordinators"
./functions/add-realm-role-to-group.sh "$REALM" "${WORKSPACE_NAME}-coordinators" "workspace-coordinator"
./functions/add-realm-role-to-group.sh "$REALM" "${WORKSPACE_NAME}-coordinators" "coordinator-${WORKSPACE_NAME}"
./functions/add-client-role-to-group.sh "$REALM" "${WORKSPACE_NAME}-coordinators" "realm-management" "view-users"
echo "Associated group and role for coordinators"

# Ensure that the coordinators can manage members of the users group
./functions/add-role-policy.sh "$REALM" "coordinator-${WORKSPACE_NAME}" "coordinator-${WORKSPACE_NAME}"
./functions/enable-permissions-for-group.sh "$REALM" "${WORKSPACE_NAME}-users"

# Update permission, as adding a new one does not work as expected
GROUP_ID=$(./functions/get-group-id.sh "$REALM" "${WORKSPACE_NAME}-users")
./functions/update-permission.sh "$REALM" "manage.membership.permission.group.$GROUP_ID" "workspace-coordinator"
echo "Allowed coordinators to manage members of users group"

# Create the testuser specified in parameters
./functions/create-user.sh "$REALM" "$TESTUSER_USERNAME" "$TESTUSER_FIRSTNAME" "$TESTUSER_LASTNAME" "$TESTUSER_PASSWORD"
./functions/add-user-to-group.sh "$REALM" "$TESTUSER_USERNAME" "${WORKSPACE_NAME}-users"

# Create a first coordinator specified in parameters
./functions/create-user.sh "$REALM" "$COORDINATOR_USERNAME" "$COORDINATOR_FIRSTNAME" "$COORDINATOR_LASTNAME" "$COORDINATOR_PASSWORD"
./functions/add-user-to-group.sh "$REALM" "$COORDINATOR_USERNAME" "${WORKSPACE_NAME}-users"
./functions/add-user-to-group.sh "$REALM" "$COORDINATOR_USERNAME" "${WORKSPACE_NAME}-coordinators"

# Create a number of additional testusers
if [ "$ADDITIONAL_TEST_USERS" == "true" ]; then
    ./functions/add-test-users.sh "$REALM" "$WORKSPACE_NAME"
fi

# Setup public and private clients for the current realm
./functions/add-private-client.sh "$REALM" "${WORKSPACE_NAME}-pluto" "$CLIENT_SECRET" "$PLUTO_URL" "$AFTER_LOGOUT_URL"
./functions/add-public-client.sh "$REALM" "${WORKSPACE_NAME}-public" "$PLUTO_URL" "$AFTER_LOGOUT_URL"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
exit 0
