#!/bin/sh
#
# This script adds a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group to create
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
GROUP_NAME=$2

sed \
    -e "s/\${GROUP_NAME}/$GROUP_NAME/g" \
    ../workspace-config/group.json | \
    kcadm.sh create groups -r "$REALM" -f -
