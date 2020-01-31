#!/bin/sh
#
# This script creates a realm role along with a group that provides the role to its members.
#
# Required arguments to this script are:
#   realm:              Realm to create the role and group in
#   purpose:            Purpose of role/group to create. Is used to generate role name and group name.
#                       Is assumed to be singular (e.g. user, coordinator or datasteward)
#   fairspace-name:     Name of the fairspace to generate role and group for
#   role-description:   Description of the role to create
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
PURPOSE=$2
fairspace_NAME=$3
DESCRIPTION=$4

ROLE_NAME="${PURPOSE}-${fairspace_NAME}"
GROUP_NAME="${fairspace_NAME}-${PURPOSE}s"

$DIR/add-role.sh "$REALM" "${ROLE_NAME}" "${DESCRIPTION}"
$DIR/add-group.sh "$REALM" "${GROUP_NAME}"
GROUP_ID=$($DIR/get-group-id.sh "$REALM" "${GROUP_NAME}")
$DIR/add-realm-role-to-group.sh "$REALM" "$GROUP_ID" "${ROLE_NAME}"

echo $GROUP_ID
