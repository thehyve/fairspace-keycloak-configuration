#!/bin/sh
#
# This script adds a public workspace client to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   client_id:          Client ID for the client to create
#   pluto-url:          Firstname of the user
#   after-logout-url:    Lastname of the user
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
CLIENT_ID=$2
PLUTO_URL=$3
AFTER_LOGOUT_URL=$4

sed \
    -e "s/\${CLIENT_ID}/$CLIENT_ID/g" \
    -e "s#\${PLUTO_URL}#$PLUTO_URL#g" \
    -e "s#\${AFTER_LOGOUT_URL}#$AFTER_LOGOUT_URL#g" \
    ../workspace-config/public-client.json | \
    kcadm.sh create clients -r "$REALM" -f -

./add-client-mapper.sh "$REALM" "$CLIENT_ID"
