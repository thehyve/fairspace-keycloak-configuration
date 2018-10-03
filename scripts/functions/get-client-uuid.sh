#!/bin/sh
#
# This script returns the client UUID for the given client name
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   client-name:         Name of the client
#
# An authenticated session for keycloak is assumed to be present.
#

REALM=$1
CLIENT_ID=$2

CLIENT_UUID=$(kcadm.sh get clients -r "$REALM" -q clientId="$CLIENT_ID" --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$CLIENT_UUID" ]; then
    >&2 echo "No client UUID could be found for client $CLIENT_ID"
    exit 1
fi

echo $CLIENT_UUID
