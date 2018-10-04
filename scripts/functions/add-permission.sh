#!/bin/sh
#
# This script adds a permission
#
# Required arguments to this script are:
#   realm:              Realm to work in
#   permission-name:    Name of the permission to create
#   resource-name:      Name of the resource (for e.g groups, use the ID)
#   scope_name:         Name of the scope
#   policy-name:        Name of the policy to apply
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
PERMISSION_NAME=$2
RESOURCE_NAME=$3
SCOPE_NAME=$4
POLICY_NAME=$5

RESOURCE_ID=$(${DIR}/get-resource-id.sh "$REALM" "$RESOURCE_NAME")
if [ $? -ne 0 ]; then exit 1; fi

SCOPE_ID=$(${DIR}/get-scope-id.sh "$REALM" "$RESOURCE_NAME" "$SCOPE_NAME")
if [ $? -ne 0 ]; then exit 1; fi

POLICY_ID=$(${DIR}/get-policy-id.sh "$REALM" "$POLICY_NAME")
if [ $? -ne 0 ]; then exit 1; fi

REALM_MANAGEMENT_UUID=$($DIR/get-realm-management-uuid.sh "$REALM")
if [ $? -ne 0 ]; then exit 1; fi

sed \
    -e "s/\${PERMISSION_NAME}/$PERMISSION_NAME/g" \
    -e "s/\${RESOURCE_ID}/$RESOURCE_ID/g" \
    -e "s/\${SCOPE_ID}/$SCOPE_ID/g" \
    -e "s/\${POLICY_ID}/$POLICY_ID/g" \
    ${DIR}/../workspace-config/permission.json | \
    kcadm.sh create clients/$REALM_MANAGEMENT_UUID/authz/resource-server/permission/scope -r "$REALM" -f -
