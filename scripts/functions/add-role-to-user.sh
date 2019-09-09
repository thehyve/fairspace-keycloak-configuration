#!/bin/sh
#
# This script adds a user to a group to keycloak
#
# Required arguments to this script are:
#   realm:             Realm to store the user in
#   user-id:           UUID of the user to add
#   role-id:           UUID of the role to add the user to
#   role-name:         Name of the role to add the user to
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
USER_ID=$2
ROLE_ID=$3
ROLE_NAME=$4

sed \
    -e "s/\${ROLE_ID}/$ROLE_ID/g" \
    -e "s#\${ROLE_NAME}#$ROLE_NAME#g" \
    ${DIR}/../workspace-config/role-mapping.json | \
    kcadm.sh create users/$USER_ID/role-mappings/realm -r "$REALM" -f -
