#!/bin/sh
#
# This script removes a role from keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   role-name:          Name of the role to create
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
ROLE_NAME=$2

ROLE_ID=$(./functions/get-role-id.sh "$REALM" "$ROLE_NAME")

kcadm.sh delete roles-by-id/$ROLE_ID -r "$REALM"
