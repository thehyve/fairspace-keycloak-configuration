#!/bin/sh
#
# This script adds a permission
#
# Required arguments to this script are:
#   realm:              Realm to work in
#   permission-name:    Name of the permission to update
#   policy-name:        Name of the policy to apply
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
PERMISSION_NAME=$2
POLICY_NAME=$3

PERMISSION_ID=$(${DIR}/get-permission-id.sh "$REALM" "$PERMISSION_NAME")
if [ $? -ne 0 ]; then exit 1; fi

POLICY_ID=$(${DIR}/get-policy-id.sh "$REALM" "$POLICY_NAME")
if [ $? -ne 0 ]; then exit 1; fi

REALM_MANAGEMENT_UUID=$($DIR/get-realm-management-uuid.sh "$REALM")
if [ $? -ne 0 ]; then exit 1; fi

sed \
    -e "s/\${PERMISSION_NAME}/$PERMISSION_NAME/g" \
    -e "s/\${POLICY_ID}/$POLICY_ID/g" \
    ${DIR}/../workspace-config/update-permission.json | \
    kcadm.sh update clients/$REALM_MANAGEMENT_UUID/authz/resource-server/permission/scope/$PERMISSION_ID -r "$REALM" -f -
