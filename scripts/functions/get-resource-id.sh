#!/bin/sh
#
# This script returns the resource ID for the given id
#
# Required arguments to this script are:
#   realm:              Realm
#   entity-id:          ID of the entity to search for
#
# An authenticated session for keycloak is assumed to be present.
#

DIR=$(dirname "$0")
REALM=$1
ENTITY_ID=$2

RESOURCE_ID=$(kcadm.sh get clients/$REALM_MANAGEMENT_UUID/authz/resource-server/resource -r "$REALM" -q name=$ENTITY_ID --fields "_id" --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$RESOURCE_ID" ]; then
    >&2 echo "No resource ID could be found for entity $ENTITY_ID"
    exit 1
fi

echo $RESOURCE_ID
