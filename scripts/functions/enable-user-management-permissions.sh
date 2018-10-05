#!/bin/sh
#
# This script enables permissions for user-management
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1

echo "{\"enabled\": true}" | \
    kcadm.sh update users-management-permissions -r "$REALM" -f -
