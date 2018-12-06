#!/bin/sh
#
# This script returns the scope ID for the given scope and entity
#
# Required arguments to this script are:
#   realm:              Realm
#   entity-id:          ID of the entity to search for
#   scope-name:         Name of the scope to search for
#
# An authenticated session for keycloak is assumed to be present.
#

DIR=$(dirname "$0")
REALM=$1
ENTITY_ID=$2
SCOPE_NAME=$3

SCOPE_ID=$(kcadm.sh get clients/$REALM_MANAGEMENT_UUID/authz/resource-server/resource -r $REALM -q name=$ENTITY_ID | jq -r ".[0].scopes[] | select(.name==\"$SCOPE_NAME\") | .id")

if [ $? -ne 0 ] || [ -z "$SCOPE_ID" ]; then
    >&2 echo "No scope ID could be found for entity $ENTITY_ID and scope $SCOPE_NAME"
    exit 1
fi

echo $SCOPE_ID
