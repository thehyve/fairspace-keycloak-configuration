#!/bin/sh
#
# This script adds a client role as composite role for another realm role
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   parent-role-id:     UUID of the role to add the composite role to
#   client-id:
#   client-role-name:
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
PARENT_ROLE_ID=$2
CLIENT_ID=$3
ROLE_NAME=$4

echo "[" $(kcadm.sh get-roles -r "$REALM" --cclientid "$CLIENT_ID" --rolename "$ROLE_NAME") "]" | \
    kcadm.sh create roles-by-id/$PARENT_ROLE_ID/composites -r "$REALM" -f -

