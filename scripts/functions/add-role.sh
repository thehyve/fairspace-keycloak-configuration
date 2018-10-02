#!/bin/sh
#
# This script adds a role to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   role-name:          Name of the role to create
#   role-description:   Description of the role to create
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
ROLE_NAME=$2
ROLE_DESCRIPTION=$3

sed \
    -e "s/\${ROLE_NAME}/$ROLE_NAME/g" \
    -e "s/\${ROLE_DESCRIPTION}/$ROLE_DESCRIPTION/g" \
    ../workspace-config/role.json | \
    kcadm.sh create roles -r "$REALM" -f -
