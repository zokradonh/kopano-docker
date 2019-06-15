ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_php

ARG VCS_REF
ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG ADDITIONAL_KOPANO_WEBAPP_PLUGINS=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_WEBAPP_REPOSITORY_URL="file:/kopano/repo/webapp"
ARG KOPANO_WEBAPP_SMIME_REPOSITORY_URL="file:/kopano/repo/smime"
ARG KOPANO_WEBAPP_MDM_REPOSITORY_URL="file:/kopano/repo/mdm"
ARG KOPANO_WEBAPP_FILES_REPOSITORY_URL="file:/kopano/repo/files"
ARG KOPANO_WEBAPP_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    ADDITIONAL_KOPANO_WEBAPP_PLUGINS=$ADDITIONAL_KOPANO_WEBAPP_PLUGINS \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
    RELEASE_KEY_DOWNLOAD=$RELEASE_KEY_DOWNLOAD \
    KOPANO_WEBAPP_REPOSITORY_URL=$KOPANO_WEBAPP_REPOSITORY_URL \
    KOPANO_WEBAPP_SMIME_REPOSITORY_URL=$KOPANO_WEBAPP_SMIME_REPOSITORY_URL \
    KOPANO_WEBAPP_MDM_REPOSITORY_URL=$KOPANO_WEBAPP_MDM_REPOSITORY_URL \
    KOPANO_WEBAPP_FILES_REPOSITORY_URL=$KOPANO_WEBAPP_FILES_REPOSITORY_URL \
    KOPANO_WEBAPP_VERSION=$KOPANO_WEBAPP_VERSION

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano WebApp container" \
    org.label-schema.description="Container for running Kopano WebApp" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_WEBAPP_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano WebApp and refresh ca-certificates
# hadolint ignore=SC2129
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "webapp"; \
        dl_and_package_community "files"; \
        dl_and_package_community "mdm"; \
        dl_and_package_community "smime"; \
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

COPY start.sh /kopano/start.sh

ENV LANG en_US.UTF-8

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]
