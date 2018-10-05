#!/bin/sh
#
# This script returns the permission ID for the given permission
#
# Required arguments to this script are:
#   realm:              Realm
#   permission-name:        Name of the permission to search for
#
# An authenticated session for keycloak is assumed to be present.
#

DIR=$(dirname "$0")
REALM=$1
PERMISSION_NAME=$2

REALM_MANAGEMENT_UUID=$($DIR/get-realm-management-uuid.sh "$REALM")
if [ $? -ne 0 ]; then exit 1; fi

PERMISSION_ID=$(kcadm.sh get clients/$REALM_MANAGEMENT_UUID/authz/resource-server/permission -r "$REALM" -q "name=$PERMISSION_NAME" -q max=1 --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$PERMISSION_ID" ]; then
    >&2 echo "No permission ID could be found for name $PERMISSION_NAME"
    exit 1
fi

echo $PERMISSION_ID
