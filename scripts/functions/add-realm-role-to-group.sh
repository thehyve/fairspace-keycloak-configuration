#!/bin/sh
#
# This script adds a realm role to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group to create
#   role-name:          Name of the role to add
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
GROUP_NAME=$2
ROLE_NAME=$3
GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$GROUP_NAME" --fields id --format csv --noquotes)
echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/realm -r "$REALM" -f -
