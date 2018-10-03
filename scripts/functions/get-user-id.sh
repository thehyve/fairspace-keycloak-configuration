#!/bin/sh
#
# This script returns the user id for the given username
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   user-name:         Name of the user
#
# An authenticated session for keycloak is assumed to be present.
#

REALM=$1
USERNAME=$2

USER_ID=$(kcadm.sh get users -r "$REALM" -q username="$USERNAME" --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$USER_ID" ]; then
    >&2 echo "No user ID could be found for user $USERNAME"
    exit 1
fi

echo $USER_ID
