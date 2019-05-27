ARG CODE_VERSION=1.2.4
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_ldap:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

COPY bootstrap /container/service/slapd/assets/config/bootstrap
