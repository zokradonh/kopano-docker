# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_php

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG ADDITIONAL_KOPANO_WEBAPP_PLUGINS=""
ARG DEBIAN_FRONTEND=noninteractive
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG KOPANO_WEBAPP_FILES_REPOSITORY_URL="file:/kopano/repo/files"
ARG KOPANO_WEBAPP_MDM_REPOSITORY_URL="file:/kopano/repo/mdm"
ARG KOPANO_WEBAPP_REPOSITORY_URL="file:/kopano/repo/webapp"
ARG KOPANO_WEBAPP_SMIME_REPOSITORY_URL="file:/kopano/repo/smime"
ARG KOPANO_WEBAPP_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    ADDITIONAL_KOPANO_WEBAPP_PLUGINS=$ADDITIONAL_KOPANO_WEBAPP_PLUGINS \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
    KOPANO_WEBAPP_FILES_REPOSITORY_URL=$KOPANO_WEBAPP_FILES_REPOSITORY_URL \
    KOPANO_WEBAPP_MDM_REPOSITORY_URL=$KOPANO_WEBAPP_MDM_REPOSITORY_URL \
    KOPANO_WEBAPP_REPOSITORY_URL=$KOPANO_WEBAPP_REPOSITORY_URL \
    KOPANO_WEBAPP_SMIME_REPOSITORY_URL=$KOPANO_WEBAPP_SMIME_REPOSITORY_URL \
    KOPANO_WEBAPP_VERSION=$KOPANO_WEBAPP_VERSION \
    LANG=en_US.UTF-8

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano WebApp container" \
    org.label-schema.description="Container for running Kopano WebApp" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_WEBAPP_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano WebApp
# hadolint ignore=SC2129
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    # community download and package as apt source repository
    # TODO is it neccesary to source this file here? was already sourced before
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "webapp" "Debian_10"; \
        dl_and_package_community "files" "Debian_10"; \
        dl_and_package_community "mdm" "Debian_10"; \
        dl_and_package_community "smime" "Debian_10"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_SMIME_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_MDM_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_FILES_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    # install
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        kopano-webapp \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        ${ADDITIONAL_KOPANO_WEBAPP_PLUGINS} \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# tweak to make the container read-only
RUN mkdir -p /tmp/webapp/ && \
    for i in /etc/kopano/webapp/* /etc/kopano/webapp/.[^.]*; do \
        mv "$i" "$i.dist"; \
        ln -s /tmp/webapp/"$(basename "$i")" "$i"; \
    done

COPY kopano-webapp.conf /etc/php/7.3/fpm/pool.d/
COPY kweb.cfg /etc/kweb.cfg
COPY start.sh /kopano/start.sh
COPY goss* /goss/

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]

HEALTHCHECK --interval=1m --timeout=10s \
    CMD goss -g /goss/goss.yaml validate

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF