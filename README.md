# Keycloak configuration scripts

This repository contains configuration scripts to configure
keycloak when installing a new hyperspace.
The scripts are usually executed via helm post-install hooks.

### Structure of keycloak concepts

This section describes the mapping of Keycloak concepts to Fairspace concepts.

### Hyperspace

Within keycloak, a hyperspace corresponds with a realm.

### Workspace

A hyperspace can be shared by multiple workspaces. Each workspace should have a public
and a private OIDC authentication client in Keycloak.


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
  -e "KEYCLOAK_URL=http://172.17.0.1:5100/auth" \
  keycloak-config
```

That would allow you to run the `setup-keycloak-hyperspace.sh` script as follows:

```
./setup-keycloak-hyperspace.sh $KEYCLOAK_URL $KEYCLOAK_USER
```

Please note that the docker -v command requires the absolute path to the scripts
directory to work properly.

## License

Copyright (c) 2021 The Hyve B.V.

This program is free software: you can redistribute it and/or modify it under the terms of the Apache 2.0
License published by the Apache Software Foundation, either version 2.0 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the Apache 2.0 License for more details.

You should have received a copy of the Apache 2.0 License along with this program (see [LICENSE](LICENSE)). If not, see https://www.apache.org/licenses/LICENSE-2.0.txt.
