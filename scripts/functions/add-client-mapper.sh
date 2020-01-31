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
DIR=$(dirname "$0")
REALM=$1
CLIENT_ID=$2

CLIENT_UUID=$(${DIR}/get-client-uuid.sh "$REALM" "$CLIENT_ID")
if [ $? -ne 0 ]; then exit 1; fi

cat ${DIR}/../fairspace-config/authorities-client-mapper.json | \
    kcadm.sh create clients/$CLIENT_UUID/protocol-mappers/models -r "$REALM" -f -
