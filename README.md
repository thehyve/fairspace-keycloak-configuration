# Keycloak configuration scripts

This repository contains configuration scripts to setup
keycloak when installing a new hyperspace of workspace.
The scripts are executed from helm post-install hooks, with 
the appropriate parameters.

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

Please note that the docker -v command requires the absolute path to the scripts
directory to work properly.  
