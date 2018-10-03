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
DIR=$(dirname "$0")
REALM=$1
GROUP_NAME=$2
ROLE_NAME=$3

GROUP_ID=$(${DIR}/get-group-id.sh "$REALM" "$GROUP_NAME")
if [ $? -ne 0 ]; then exit 1; fi

echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/realm -r "$REALM" -f -
