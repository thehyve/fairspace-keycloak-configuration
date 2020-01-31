#!/bin/sh
#
# This scripts adds some additional test users to keycloak
# for logging into or coordinating the fairspace
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1

source $DIR/../config.sh

for i in "${!USERNAMES[@]}"; do
    USERNAME="${USERNAMES[$i]}"
    FIRSTNAME=${FIRSTNAMES[$i]}
    LASTNAME=${LASTNAMES[$i]}

    $DIR/create-user.sh "$REALM" "$USERNAME" "$FIRSTNAME" "$LASTNAME" "$TESTUSER_PASSWORD"

    echo "  User $USERNAME ($FIRSTNAME $LASTNAME)"
done
