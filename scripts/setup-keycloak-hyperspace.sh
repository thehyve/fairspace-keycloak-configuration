#!/bin/bash
#
# This script sets up keycloak for a single hyperspace
#
# Required arguments to this script are:
#   url:      Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username: Username of the administrative user to login
#
# The password is expected to be set as environment variable KEYCLOAK_PASSWORD
#
echo "Setting up Hyperspace in keycloak ..."
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
USER="$2"

# Wait for the server to be online. This may take a while, as the webserver waits for postgres
# If the server will not be up after 5 minutes, the script will die and helm will start a new container
./wait-for-server-to-respond.sh "$SERVER" || exit 1

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm master --server "$SERVER" --user "$USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak Hyperspace script finished."
exit 0
