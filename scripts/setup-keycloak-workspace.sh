#!/bin/bash
#
# This script sets up keycloak for a single workspace
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   realm:        Name of the realm to perform actions in
#   workspace:    Name of the workspace to create
#   username:     Name of the testuser to create. Defaults to 'test-$WORKSPACE_NAME'
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
# The testuser password is expected to be set as environment variable TESTUSER_PASSWORD
#
echo "Setting up workspace in keycloak"
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
USER="$2"
REALM="$3"
WORKSPACE_NAME="$4"
TESTUSER_NAME="${5:-test-$WORKSPACE_NAME}"

# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Initialize a role and group
sed -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/use-workspace-role.json | \
    kcadm.sh create roles -r "$REALM" -f -
sed -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/workspace-users-group.json | \
    kcadm.sh create groups -r "$REALM" -f -

# Add the role to the group
GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$WORKSPACE_NAME-users" --fields id --format csv --noquotes)
echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "user-$WORKSPACE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/realm -r "$REALM" -f -

# Create test user
sed -e "s/\${TESTUSER_NAME}/$TESTUSER_NAME/g" -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/test-user.json | \
    kcadm.sh create users -r "$REALM" -f -
kcadm.sh set-password -r "$REALM" --username "$TESTUSER_NAME" --new-password "$TESTUSER_PASSWORD"

# Add the user to the group
USER_ID=$(kcadm.sh get users -r "$REALM" -q username="$TESTUSER_NAME" --fields id --format csv --noquotes)
kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r "$REALM" -s realm=$REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n

# Setup first client
sed -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/pluto-client.json | \
    kcadm.sh create clients -r "$REALM" -f -

# Add authorizations mapper to the client
CLIENT_ID=$(kcadm.sh get clients -r "$REALM" -q clientId="$WORKSPACE_NAME-pluto" --fields id --format csv --noquotes)
cat ./workspace-config/authorities-client-mapper.json | \
    kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r "$REALM" -f -
