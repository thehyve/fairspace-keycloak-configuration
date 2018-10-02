#!/bin/sh
#
# This script adds a client role to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group to create
#   client-id:          Client ID (not UUID) of the client
#   role-name:          Name of the role to add
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
GROUP_NAME=$2
CLIENT_ID=$3
ROLE_NAME=$4

GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$GROUP_NAME" --fields id --format csv --noquotes)
CLIENT_UUID=$(kcadm.sh get clients -r "$REALM" -q clientId="$CLIENT_ID" --fields id --format csv --noquotes)

echo "[" $(kcadm.sh get-roles -r "$REALM" --cclientid "$CLIENT_ID" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/clients/$CLIENT_UUID -r "$REALM" -f -

