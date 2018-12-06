#!/bin/sh
#
# This script adds a user to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   user-id:            UUID of the user to add
#   group-id:           UUID of the group to add the user to
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
USER_ID=$2
GROUP_ID=$3

kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r "$REALM" -s realm=$REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n
