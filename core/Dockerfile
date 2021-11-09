# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_KAPPS_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    GRAPI_BACKEND="kopano" \
    KCCONF_GRAPI_LDAP_BASEDN="" \
    KCCONF_GRAPI_LDAP_BINDDN="" \
    KCCONF_GRAPI_LDAP_BINDPW_FILE="" \
    KCCONF_GRAPI_LDAP_URI="" \
    KOPANO_CONFIG_PATH=/tmp/kopano \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    LANG=en_US.UTF-8 \
    SERVICE_TO_START=server

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Groupware Core container" \
    org.label-schema.description="Container for running applications out of Kopano Groupware Core" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_CORE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano Core and refresh ca-certificates
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    --mount=type=bind,target=/kopano/repo,source=/kopano/repo,from=zokradonh/kopano_repo_helper \
    --mount=type=bind,target=/etc/apt/sources.list.d/,source=/etc/apt/sources.list.d/,from=zokradonh/kopano_repo_helper \
    # install
    apt-get update && \
    set -x && \
    apt-get -o Debug::pkgProblemResolver=true install --no-install-recommends -y \
        kopano-server-packages kopano-spamd \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        && \
    coreversion=$(dpkg-query --showformat='${Version}' --show kopano-server) && \
    if dpkg --compare-versions "$coreversion" "gt" "8.7.0"; then \
        # For grapi also install recommended packages
        apt-get -o Debug::pkgProblemResolver=true install -y \
            kopano-grapi kopano-kapid; \
    fi && \
    if dpkg --compare-versions "$coreversion" "gt" "8.7.84"; then \
        apt-get -o Debug::pkgProblemResolver=true install --no-install-recommends -y \
            python3-grapi.backend.ldap; \
    fi && \
    set +x && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    touch /etc/kopano/admin.cfg && \
    # with 9.0 config files are once again in /etc/kopano
    (cp /usr/share/doc/kopano/example-config/*.cfg /etc/kopano/ || true) && \
    (cp /usr/share/doc/kopano/example-config/*.cfg.gz /etc/kopano/ || true) && \
    (gzip -d -f /etc/kopano/*.gz || true)

COPY defaultconfigs/ start-service.sh healthcheck.sh /kopano/
COPY bin/ /usr/local/bin/
COPY goss/ /kopano/goss

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD [ "/kopano/start-service.sh" ]

HEALTHCHECK --interval=1m --timeout=10s \
    CMD /kopano/healthcheck.sh

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF