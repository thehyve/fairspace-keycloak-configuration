#!/bin/sh
#
# This script returns the group ID for the given group name
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group
#
# An authenticated session for keycloak is assumed to be present.
#

REALM=$1
GROUP_NAME=$2

GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$GROUP_NAME" --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$GROUP_ID" ]; then
    >&2 echo "No group ID could be found for group $GROUP_NAME"
    exit 1
fi

echo $GROUP_ID
