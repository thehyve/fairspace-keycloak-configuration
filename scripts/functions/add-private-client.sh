#!/bin/sh
#
# This script adds a private workspace client to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   client_id:          Client ID for the client to create
#   pluto-url:          Firstname of the user
#   after-logout-url:    Lastname of the user
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
CLIENT_ID=$2
CLIENT_SECRET=$3
REDIRECT_URL_FILE=$4

# Generate a list of quotes redirect urls
QUOTED_REDIRECT_URLS=$($DIR/parse-file-to-json-array.sh $REDIRECT_URL_FILE)

sed \
    -e "s/\${CLIENT_ID}/$CLIENT_ID/g" \
    -e "s/\${CLIENT_SECRET}/$CLIENT_SECRET/g" \
    -e "s#\${QUOTED_REDIRECT_URLS}#$QUOTED_REDIRECT_URLS#g" \
    ${DIR}/../workspace-config/private-client.json | \
    kcadm.sh create clients -r "$REALM" -f -

${DIR}/add-client-mapper.sh "$REALM" "$CLIENT_ID"
