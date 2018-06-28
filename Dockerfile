FROM jboss/keycloak:3.4.3.Final

COPY scripts/ /opt/jboss/scripts

WORKDIR /opt/jboss/scripts

ENTRYPOINT [ "/bin/sh" ]
