# Keycloak configuration scripts

This repository contains configuration scripts to configure
keycloak when installing a new hyperspace of fairspace.
The scripts are usually executed via helm post-install hooks.

### Structure of keycloak concepts
This section describes the mapping of Keycloak concepts to Fairspace concepts.

### Hyperspace
Within keycloak, a hyperspace corresponds with a realm. When setting it up, two roles are added:
* `fairspace-coordinator`, that allows one to actually add
users to groups. Please note that a user needs specific permissions on group level
to actually manage group membership. See the next paragraph.
* `organisation-admin`, that allows to create new fairspaces

### fairspace

A hyperspace can be shared by multiple fairspaces. Each fairspace has a public
and a private OIDC authentication client in Keycloak.

The scripts create three user groups per fairspace:
* _<fairspace>-coordinators_: members of this group can manage membership
  of the `<fairspace>-users` and `<fairspace>-datastewards` groups using the security admin
  console. The `fairspace-coordinator` and `coordinator-<fairspace>` roles are mapped to this
  group.

* _<fairspace>-users_: members of this group can use the fairspace. Nonmembers can
  log in, but will not be able to use the application. The `user-<fairspace>` role is mapped
  to this group.

* _<fairspace>-datastewards_: members of this group can edit the vocabulary. The
  `datasteward-<fairspace>` role is mapped to this group.


## Keycloak admin api

The configurations scripts make use of the `kcadm.sh` script
that calls the keycloak admin api from the command line.
This simplifies the usage of the api a bit. More information can be
found in [the Keycloak admin CLI documentation](https://www.keycloak.org/docs/3.4/server_admin/#the-admin-cli).

The scripts and their dependencies are packaged in a Docker container.

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
  -e "ORGANISATION_ADMIN_PASSWORD=verySecret02" \
  -e "CLIENT_SECRET=ed8722df-d968-4990-869c-88424a83512c" \
  -e "KEYCLOAK_URL=http://172.17.0.1:5100/auth" \
  -e "REALM=test" \
  -e "fairspace=test" \
  -e "URL_FILE=/opt/jboss/redirect-urls" \
  keycloak-config
```

That would allow you to run the `setup-keycloak-fairspace.sh` script as follows:

```
./setup-keycloak-hyperspace.sh $KEYCLOAK_URL $KEYCLOAK_USER $REALM $URL_FILE
./setup-keycloak-fairspace.sh $KEYCLOAK_URL $KEYCLOAK_USER $REALM $fairspace $URL_FILE
```

Please note that the docker -v command requires the absolute path to the scripts
directory to work properly.

  
