#!/bin/sh
#
# This script enables permissions for the given role
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   role-id:            UUID of the role to enable permissions for
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
ROLE_ID=$2

echo "{\"enabled\": true}" | \
    kcadm.sh update roles-by-id/$ROLE_ID/management/permissions -r "$REALM" -f -
