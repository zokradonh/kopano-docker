# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    DOWNLOAD_BRANCH="" \
    DOWNLOAD_CHANNEL="community" \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    DOWNLOAD_DISTRIBUTION="Debian_10" \
    GRAPI_BACKEND="kopano" \
    KCCONF_GRAPI_LDAP_BASEDN="" \
    KCCONF_GRAPI_LDAP_BINDDN="" \
    KCCONF_GRAPI_LDAP_BINDPW_FILE="" \
    KCCONF_GRAPI_LDAP_URI="" \
    KOPANO_CONFIG_PATH=/tmp/kopano \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
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
# hadolint currently does not understand the extended buildkit syntax https://github.com/hadolint/hadolint/issues/347
# hadolint ignore=SC2215,DL3015
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    # apt key for this repo has already been installed in base
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
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