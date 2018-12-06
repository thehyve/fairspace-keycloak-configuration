#!/bin/sh
#
# This script enables permissions for the given group
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-id:           UUID of the group to enable permissions for
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
GROUP_ID=$2

echo "{\"enabled\": true}" | \
    kcadm.sh update groups/$GROUP_ID/management/permissions -r "$REALM" -f -
