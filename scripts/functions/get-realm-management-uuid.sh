#!/bin/sh
#
# This script returns the client UUID for Realm-Management

# Required arguments to this script are:
#   realm:              Realm to store the user in
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1

$DIR/get-client-uuid.sh "$REALM" "realm-management"
