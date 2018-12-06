#!/bin/sh
#
# This script adds a realm role to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-id:           UUID of the group to add the role to
#   role-name:          Name of the role to add
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
GROUP_ID=$2
ROLE_NAME=$3

echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create groups/$GROUP_ID/role-mappings/realm -r "$REALM" -f -
