#!/bin/sh
#
# This script removes a client from keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   client-id:          ID of the client to delete (not UUID)
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
CLIENT_ID=$2

CLIENT_UUID=$(./functions/get-client-uuid.sh "$REALM" "$CLIENT_ID")

kcadm.sh delete clients/$CLIENT_UUID -r "$REALM"
