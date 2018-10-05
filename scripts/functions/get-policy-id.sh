#!/bin/sh
#
# This script returns the policy ID for the given policy
#
# Required arguments to this script are:
#   realm:              Realm
#   policy-name:        Name of the policy to search for
#
# An authenticated session for keycloak is assumed to be present.
#

DIR=$(dirname "$0")
REALM=$1
POLICY_NAME=$2

REALM_MANAGEMENT_UUID=$($DIR/get-realm-management-uuid.sh "$REALM")
if [ $? -ne 0 ]; then exit 1; fi

POLICY_ID=$(kcadm.sh get clients/$REALM_MANAGEMENT_UUID/authz/resource-server/policy -r "$REALM" -q "name=$POLICY_NAME" -q max=1 --fields id --format csv --noquotes)

if [ $? -ne 0 ] || [ -z "$POLICY_ID" ]; then
    >&2 echo "No policy ID could be found for name $POLICY_NAME"
    exit 1
fi

echo $POLICY_ID
