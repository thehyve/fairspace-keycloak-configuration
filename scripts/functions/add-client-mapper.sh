#!/bin/sh
#
# This script adds a authorities mapper to the given client
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   client_id:          Client ID for the client to add a mapper for
#
# An authenticated session for keycloak is assumed to be present.
#

REALM=$1
CLIENT_ID=$2

CLIENT_UUID=$(kcadm.sh get clients -r "$REALM" -q clientId="$CLIENT_ID" --fields id --format csv --noquotes)
cat ../workspace-config/authorities-client-mapper.json | \
    kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r "$REALM" -f -
