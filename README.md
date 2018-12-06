# Keycloak configuration scripts

This repository contains configuration scripts to setup
keycloak when installing a new hyperspace of workspace.
The scripts are executed from helm post-install hooks, with 
the appropriate parameters.

### Structure of keycloak concepts
This paragraph describes the structure of the keycloak concepts and the mapping
to fairspace concepts.

### Hyperspace 
Within keycloak, a hyperspace corresponds with a realm. When setting it up, a
realm role `workspace-coordinator` is created, that allows one to actually add
users to groups. Please note that a user needs specific permissions on group level 
to actually manage group membership. See the next paragraph. 

### Workspace
Within a hyperspace there can be many workspaces. For each workspace, a public 
and a private client are created to do OIDC authentication. 

Additionally, 2 user groups are created: 
* _coordinators-<workspace>_ This group allows members to coordinate the workspace, i.e.
  to manage membership of the group _users-<workspace>_. This effectively lets a coordinator
  decide who can login to the workspace.
  
  To be exact: this group provides members with the `workspace-coordinator` and `coordinator-<workspace>`
  roles, which allow the user to manage group membership in the security-admin-console.
* _users-<workspace>_ This groups allows members to login to the workspace. Without this role, 
  users can login but will see an error message immediately.
  
  To be exact: this group provides members with the `user-<workspace>`
  role, which is checked within Pluto.

## Keycloak admin api
The configurations scripts make use of the `kcadm.sh` script
that calls the keycloak admin api from the command line.
This simplifies the usage of the api a bit. Documentation can 
be found at https://www.keycloak.org/docs/3.4/server_admin/#the-admin-cli 

The scripts are bundled into a docker container with the appropriate
command line tools.

## Local testing
You can test the scripts locally by starting the 
docker container and mounting the scripts directory inside.

The following command would do the trick:

```
docker build . --tag keycloak-config
docker run --rm -it -v <absolute-path-to-scripts>:/opt/jboss/scripts keycloak-config
```

You can also pass environment variables to work with the scripts easily. For example:

```
docker run --rm -it \
  -v <absolute-path-to-scripts>:/opt/jboss/scripts \
  -v <absolute-path-to-url-file>:/opt/jboss/redirect-urls \
  -e "KEYCLOAK_USER=keycloak" \
  -e "KEYCLOAK_PASSWORD=keycloak" \
  -e "TESTUSER_PASSWORD=welkom01" \
  -e "COORDINATOR_PASSWORD=verySecret01" \
  -e "CLIENT_SECRET=ed8722df-d968-4990-869c-88424a83512c" \
  -e "KEYCLOAK_URL=http://172.17.0.1:5100/auth" \
  -e "REALM=test" \
  -e "WORKSPACE=test" \
  -e "URL_FILE=/opt/jboss/redirect-urls" \
  keycloak-config
```

That would allow you to run the `setup-keycloak-workspace.sh` script as follows:

```
./setup-keycloak-workspace.sh $KEYCLOAK_URL $KEYCLOAK_USER $REALM $WORKSPACE $URL_FILE
```

Please note that the docker -v command requires the absolute path to the scripts
directory to work properly.

  
