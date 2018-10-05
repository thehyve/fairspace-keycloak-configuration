#!/bin/sh
#
# This script enables permissions for the given group
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group to create
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
GROUP_NAME=$2

GROUP_ID=$(${DIR}/get-group-id.sh "$REALM" "$GROUP_NAME")
if [ $? -ne 0 ]; then exit 1; fi

echo "{\"enabled\": true}" | \
    kcadm.sh update groups/$GROUP_ID/management/permissions -r "$REALM" -f -
