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

echo "Updating permission $PERMISSION_NAME with policy $POLICY_NAME"

PERMISSION_ID=$(${DIR}/get-permission-id.sh "$REALM" "$PERMISSION_NAME")
if [ $? -ne 0 ]; then >&2 echo "No permission found for permission $PERMISSION_NAME" && exit 1; fi

POLICY_ID=$(${DIR}/get-policy-id.sh "$REALM" "$POLICY_NAME")
if [ $? -ne 0 ]; then >&2 echo "No policy found for policy $POLICY_NAME" && exit 1; fi

CURRENT_POLICIES=$(kcadm.sh get clients/$REALM_MANAGEMENT_UUID/authz/resource-server/permission/scope/$PERMISSION_ID/associatedPolicies -r "$REALM" --fields id)
UPDATED_POLICIES=$(echo $CURRENT_POLICIES | jq "map(.id) + [\"$POLICY_ID\"]" | tr '\n' ' ')

sed \
    -e "s/\${PERMISSION_NAME}/$PERMISSION_NAME/g" \
    -e "s/\${POLICIES}/$UPDATED_POLICIES/g" \
    ${DIR}/../workspace-config/update-permission.json | \
    kcadm.sh update clients/$REALM_MANAGEMENT_UUID/authz/resource-server/permission/scope/$PERMISSION_ID -r "$REALM" -f -
