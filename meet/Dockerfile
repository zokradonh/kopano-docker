ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base:latest

ARG VCS_REF
ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_MEET_REPOSITORY_URL="file:/kopano/repo/meet"
ARG KOPANO_MEET_VERSION=newest
ENV KOPANO_MEET_VERSION=$KOPANO_MEET_VERSION

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
    RELEASE_KEY_DOWNLOAD=$RELEASE_KEY_DOWNLOAD

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Meet container" \
    org.label-schema.description="Container for running Kopano Meet" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_MEET_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano Core and refresh ca-certificates
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "meet"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_MEET_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    # install
    apt-get update && \
    set -x && \
    apt-get install --no-install-recommends -y \
        kopano-kwebd \
	kopano-meet kopano-meet-webapp \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        && \
    cp /usr/share/doc/kopano-meet-webapp/config.json.in /usr/share/kopano-kweb/www/config/kopano/meet.json && \
    set +x && \
    rm -rf /var/cache/apt /var/lib/apt/lists

ENV KOPANO_LOCALE="de_DE.UTF-8"
ENV KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8"
ENV LANG=en_US.UTF-8

COPY defaultconfigs/ start-service.sh /kopano/
CMD [ "/kopano/start-service.sh" ]
