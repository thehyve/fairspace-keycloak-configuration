#!/bin/bash
#
# This script sets up keycloak for a single hyperspace
#
# Required arguments to this script are:
#   url:      Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username: Username of the administrative user to login
#   realm:    Name of the realm to create
#
# The password is expected to be set as environment variable KEYCLOAK_PASSWORD
#
echo "Setting up hyperspace in keycloak"
export PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
export SERVER="$1"
export USER="$2"
export REALM="$3"

# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$USER" --password "$KEYCLOAK_PASSWORD"

# Add a realm and a hyperspace client for it
sed -e "s/\${REALM}/$REALM/" ./hyperspace-config/hyperspace-realm.json | kcadm.sh create realms -f -
cat ./hyperspace-config/hyperspace-client.json | kcadm.sh create clients -r "$REALM" -f -
