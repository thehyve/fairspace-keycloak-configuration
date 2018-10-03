#!/bin/sh
#
# This script adds a user to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   user-name:          Name of the user to add
#   group-name:         Name of the group to create
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
USERNAME=$2
GROUP_NAME=$3

GROUP_ID=$(${DIR}/get-group-id.sh "$REALM" "$GROUP_NAME")
if [ $? -ne 0 ]; then exit 1; fi

USER_ID=$(${DIR}/get-user-id.sh "$REALM" "$USERNAME")
if [ $? -ne 0 ]; then exit 1; fi

kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r "$REALM" -s realm=$REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n
