#!/bin/bash
#
# This script sets up keycloak for a single workspace
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   workspace:    Name of the workspace to create
#
# The password is expected to be set as environment variable KEYCLOAK_PASSWORD
#
echo "Setting up workspace in keycloak"
export PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
export SERVER="$1"
export USER="$2"
export WORKSPACE="$3"

# Login to keycloak first
kcadm.sh config credentials --realm master --server "$SERVER" --user "$USER" --password "$KEYCLOAK_PASSWORD"

# TODO
echo "This is the place where a workspace would be setup using kcadm.sh commands"

# Always exit succesfully to prevent restarts of the container
exit 0