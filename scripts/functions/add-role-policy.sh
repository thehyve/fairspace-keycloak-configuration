#!/bin/sh
#
# This script adds a policy for one specific role
#
# Required arguments to this script are:
#   realm:              Realm to store the user in
#   policy-name:        Name of the policy to create
#   role-name:          Name of the role that is required
#
# An authenticated session for keycloak is assumed to be present.
#
DIR=$(dirname "$0")
REALM=$1
POLICY_NAME=$2
ROLE_NAME=$3

CLIENT_UUID=$(${DIR}/get-client-uuid.sh "$REALM" "realm-management")
if [ $? -ne 0 ]; then exit 1; fi

ROLE_ID=$(${DIR}/get-role-id.sh "$REALM" "$ROLE_NAME")
if [ $? -ne 0 ]; then exit 1; fi

sed \
    -e "s/\${POLICY_NAME}/$POLICY_NAME/g" \
    -e "s/\${ROLE_ID}/$ROLE_ID/g" \
    ${DIR}/../workspace-config/policy.json | \
    kcadm.sh create clients/$CLIENT_UUID/authz/resource-server/policy/role -r "$REALM" -f -
