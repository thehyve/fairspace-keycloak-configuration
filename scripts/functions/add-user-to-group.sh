#!/bin/sh
#
# This script adds a user to a group to keycloak
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   group-name:         Name of the group to create
#   user-name:          Name of the user to add
#
# An authenticated session for keycloak is assumed to be present.
#
REALM=$1
GROUP_NAME=$2
USERNAME=$3

GROUP_ID=$(kcadm.sh get groups -r "$REALM" -q search="$GROUP_NAME" --fields id --format csv --noquotes)
USER_ID=$(kcadm.sh get users -r "$REALM" -q username="$USERNAME" --fields id --format csv --noquotes)

kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r "$REALM" -s realm=$REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n
