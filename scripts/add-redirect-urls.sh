#!/bin/bash
#
# This script adds a number of redirect urls to the client in keycloak
#
# Required arguments to this script are:
#   url:          Full url to the keycloak server, including /auth. For example: http://localhost:8080/auth
#   username:     Username of the administrative user to login
#   realm:        Name of the realm to perform actions in
#   client_id:    ID (name) of the client to update
#   redirect-url-file:   Name of the file that contains the additional redirect urls for the workspace.
#
# By default the keycloak user logs in to the master realm. However, the script can also
# be run by a realm-admin of the realm that must be configured. You can specify the LOGIN_REALM variable
# to point to the right realm to login. Please note that the user needs the realm-management/realm-admin
# to configure the workspace.
#
# The keycloak password is expected to be set as environment variable KEYCLOAK_PASSWORD
#
echo "Adding redirect urls ..."
echo "Starting at $(date -Iseconds)"
PATH=$PATH:/opt/jboss/keycloak/bin

# Set provided parameters
SERVER="$1"
KEYCLOAK_USER="$2"
REALM="$3"
CLIENT_ID="$4"
REDIRECT_URL_FILE="$5"

# See if login realm has been provided
LOGIN_REALM=${LOGIN_REALM:-master}

# Login to keycloak first
echo "Logging in ..."
kcadm.sh config credentials --realm "$LOGIN_REALM" --server "$SERVER" --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD" || exit 1

# Setup public and private clients for the current realm
echo "Adding redirect urls to client $CLIENT_ID ..."
CLIENT_UUID=$(./functions/get-client-uuid.sh "$REALM" "$CLIENT_ID")

existing_uris=$(kcadm.sh get clients/$CLIENT_UUID -r test --fields redirectUris --format csv)
new_uri_array=$(./functions/parse-file-to-json-array.sh $REDIRECT_URL_FILE)

# use bash replacement syntax to combine the existing list with the new list
# See e.g. https://stackoverflow.com/a/6744040 for details
combined_array=${new_uri_array//\[/[$existing_uris,}

echo "   Combined set of redirect urls to set: $combined_array"
kcadm.sh update clients/$CLIENT_UUID -r $REALM -s "redirectUris=$combined_array"

# Send 0 response status as some keycloak scrips may have been executed before
# In that case, the kcadm.sh script will return a non-zero response
echo "Keycloak configuration finished."
echo "Finished at $(date -Iseconds)"
exit 0
