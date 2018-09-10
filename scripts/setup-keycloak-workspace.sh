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
#   test-users:          Number of test users being created. Defaults to 5.
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
TEST_USERS=${7:-5}
TESTUSER_USERNAME="${TESTUSER_USERNAME:-test-$WORKSPACE_NAME}"

# Creates a new user. Parameters:
#   username
#   firstname
#   lastname
#   password
create_user () {
    sed \
        -e "s/\${USERNAME}/$1/g" \
        -e "s/\${FIRSTNAME}/$2/g" \
        -e "s/\${LASTNAME}/$3/g" \
        ./workspace-config/test-user.json | \
        kcadm.sh create users -r "$REALM" -f -
    kcadm.sh set-password -r "$REALM" --username "$1" --new-password "$4"
}


# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Initialize a role and group
sed -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/use-workspace-role.json | \
    kcadm.sh create roles -r "$REALM" -f -
sed -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" ./workspace-config/workspace-users-group.json | \
    kcadm.sh create groups -r "$REALM" -f -

# Add the roles (logging in to the workspace and viewing users) to the group
GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$WORKSPACE_NAME-users" --fields id --format csv --noquotes)
REALM_MGT_CLIENT_ID=$(kcadm.sh get clients -r "$REALM" -q clientId="realm-management" --fields id --format csv --noquotes)
echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "user-$WORKSPACE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/realm -r "$REALM" -f -
echo "[" $(kcadm.sh get-roles -r "$REALM" --cclientid "realm-management" --rolename "view-users") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/clients/$REALM_MGT_CLIENT_ID -r "$REALM" -f -

# Create a number of testusers
FIRSTNAMES=( "John" "Ygritte" "Daenarys"  "Gregor"  "Cersei"    "Tyrion"    "Arya"  "Sansa" "Khal"  "Joffrey"   "Sandor" )
LASTNAMES=(  "Snow" ""        "Targaryen" "Clegane" "Lannister" "Lannister" "Stark" "Stark" "Drogo" "Baratheon" "Clegane" )
if [ "$TEST_USERS" -gt "0" ] && [ "$TEST_USERS" -lt "10" ]; then
    for i in $(seq 1 $TEST_USERS); do
        if [ "$i" -eq "1" ]; then
            USERNAME=$TESTUSER_USERNAME
        else
            USERNAME="test${i}-$WORKSPACE_NAME"
        fi
        FIRSTNAME=${FIRSTNAMES[$i-1]}
        LASTNAME=${LASTNAMES[$i-1]}
        create_user "$USERNAME" "$FIRSTNAME" "$LASTNAME" "$TESTUSER_PASSWORD"
    done
fi

# Add the user to the group
USER_ID=$(kcadm.sh get users -r "$REALM" -q username="$TESTUSER_USERNAME" --fields id --format csv --noquotes)
kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r "$REALM" -s realm=$REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n

# Setup private (pluto) client
sed \
    -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" \
    -e "s/\${CLIENT_SECRET}/$CLIENT_SECRET/g" \
    -e "s#\${PLUTO_URL}#$PLUTO_URL#g" \
    -e "s#\${AFTER_LOGOUT_URL}#$AFTER_LOGOUT_URL#g" \
    ./workspace-config/pluto-client.json | \
    kcadm.sh create clients -r "$REALM" -f -

# Setup public client
sed \
    -e "s/\${WORKSPACE_NAME}/$WORKSPACE_NAME/g" \
    -e "s#\${PLUTO_URL}#$PLUTO_URL#g" \
    -e "s#\${AFTER_LOGOUT_URL}#$AFTER_LOGOUT_URL#g" \
    ./workspace-config/public-client.json | \
    kcadm.sh create clients -r "$REALM" -f -

# Add authorizations mapper to the pluto-client
CLIENT_ID=$(kcadm.sh get clients -r "$REALM" -q clientId="$WORKSPACE_NAME-pluto" --fields id --format csv --noquotes)
cat ./workspace-config/authorities-client-mapper.json | \
    kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r "$REALM" -f -

# Add authorizations mapper to the public client
CLIENT_ID=$(kcadm.sh get clients -r "$REALM" -q clientId="$WORKSPACE_NAME-public" --fields id --format csv --noquotes)
cat ./workspace-config/authorities-client-mapper.json | \
    kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r "$REALM" -f -
