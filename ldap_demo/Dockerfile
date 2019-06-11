ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_ldap

LABEL org.label-schema.description="Container for running OpenLDAP, which already has the Kopano schema included as well as users to easily demo the enviroment."

COPY bootstrap /container/service/slapd/assets/config/bootstrap
