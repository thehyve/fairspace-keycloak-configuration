#!/bin/sh
#
# This scripts adds some additional test users to keycloak
# for logging into or coordinating the workspace
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   workspace-name:     Name of the workspace to create the
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
WORKSPACE_NAME=$2

USERNAMESPREFIXES=( "user" "user2" "user3" )
COORDINATORPREFIXES=( "coordinator2" "coordinator3" )
FIRSTNAMES=( "John" "Ygritte" "Daenarys"  "Gregor"  "Cersei"    "Tyrion"    "Arya"  "Sansa" "Khal"  "Joffrey"   "Sandor" )
LASTNAMES=(  "Snow" ""        "Targaryen" "Clegane" "Lannister" "Lannister" "Stark" "Stark" "Drogo" "Baratheon" "Clegane" )

name=0

for i in "${!USERNAMESPREFIXES[@]}"; do
    USERNAME="${USERNAMESPREFIXES[$i]}-$WORKSPACE_NAME"
    FIRSTNAME=${FIRSTNAMES[$name]}
    LASTNAME=${LASTNAMES[$name]}

    $DIR/create-user.sh "$REALM" "$USERNAME" "$FIRSTNAME" "$LASTNAME" "$TESTUSER_PASSWORD"
    $DIR/add-user-to-group.sh "$REALM" "$USERNAME" "${WORKSPACE_NAME}-users"

    echo "User $USERNAME - default user"

    ((name++))
done

for i in "${!COORDINATORPREFIXES[@]}"; do
    USERNAME="${COORDINATORPREFIXES[$i]}-$WORKSPACE_NAME"
    FIRSTNAME=${FIRSTNAMES[$name]}
    LASTNAME=${LASTNAMES[$name]}

    $DIR/create-user.sh "$REALM" "$USERNAME" "$FIRSTNAME" "$LASTNAME" "$TESTUSER_PASSWORD"
    $DIR/add-user-to-group.sh "$REALM" "$USERNAME" "${WORKSPACE_NAME}-users"
    $DIR/add-user-to-group.sh "$REALM" "$USERNAME" "${WORKSPACE_NAME}-coordinators"

    echo "User $USERNAME - coordinator"

    ((name++))
done

