#!/bin/sh
#
# This script returns the role ID for the given (realm) role name
#
# Required arguments to this script are:
#   realm:              Realm
#   role-name:          Name of the role
#
# An authenticated session for keycloak is assumed to be present.
#

REALM=$1
ROLE_NAME=$2

ROLE_ID=$(kcadm.sh get roles/$ROLE_NAME -r "$REALM" --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$ROLE_ID" ]; then
    >&2 echo "No role ID could be found for role $ROLE_NAME"
    exit 1
fi

echo $ROLE_ID
