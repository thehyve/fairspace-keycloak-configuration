#!/bin/sh
#
# This script adds a realm role as composite role for another realm role
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   parent-role-id:     UUID of the role to add the composite role to
#   role-name:
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
PARENT_ROLE_ID=$2
ROLE_NAME=$3

echo "[" $(kcadm.sh get-roles -r "$REALM" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create roles-by-id/$PARENT_ROLE_ID/composites -r "$REALM" -f -

