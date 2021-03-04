# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_php

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_ZPUSH_REPOSITORY_URL="http://repo.z-hub.io/z-push:/final/Debian_10/"
ARG KOPANO_ZPUSH_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
    KOPANO_ZPUSH_REPOSITORY_URL=$KOPANO_ZPUSH_REPOSITORY_URL \
    KOPANO_ZPUSH_VERSION=$KOPANO_ZPUSH_VERSION \
    LANG=en_US.UTF-8

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Z-Push container" \
    org.label-schema.description="Container for running Z-Push with Kopano Groupware Core" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_ZPUSH_VERSION \
    org.label-schema.schema-version="1.0"

VOLUME /var/lib/z-push/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Z-Push
# hadolint currently does not understand the extended buildkit syntax https://github.com/hadolint/hadolint/issues/347
# hadolint ignore=DL3015
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    # prepare z-push installation
    echo "deb ${KOPANO_ZPUSH_REPOSITORY_URL} /" > /etc/apt/sources.list.d/zpush.list && \
    # this is the same key as for the rest of the Kopano stack, making a separate download anyways as this may not be the case in the future 
    curl -s -S -L -o - "${KOPANO_ZPUSH_REPOSITORY_URL}/Release.key" | apt-key add - && \
    # install
    set -x && \
    # TODO set IGNORE_FIXSTATES_ON_UPGRADE https://jira.z-hub.io/browse/ZP-1164
    # TODO remove php-mbstring once https://jira.z-hub.io/browse/ZP-1541 is resolved
    # TODO remove php-xml once https://jira.z-hub.io/projects/ZP/issues/ZP-1558 is resolved
    apt-get update && apt-get install -y --no-install-recommends \
        php-mbstring \
        php-xml \
        z-push-autodiscover \
        z-push-config-apache \
        z-push-config-apache-autodiscover \
        z-push-kopano \
        z-push-kopano-gabsync \
        ${ADDITIONAL_KOPANO_PACKAGES} \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# Patch Gabsync to make it work
# See https://jira.z-hub.io/browse/ZP-1463
# https://forum.kopano.io/topic/1928/8-7-80-missing-php-files-in-php-mapi-deb-package-ubuntu-16-04
# can be removed once gabsync is fixed - should not hurt
RUN sed -i -e "s/set_include_path(get_include_path() . PATH_SEPARATOR . BASE_PATH_CLI);/define('PATH_TO_ZPUSH', '..\/..\/backend\/kopano\/');\n    set_include_path(get_include_path() . PATH_SEPARATOR . BASE_PATH_CLI . PATH_SEPARATOR . BASE_PATH_CLI . PATH_TO_ZPUSH);/" /usr/share/z-push/tools/gab-sync/gab-sync.php

# tweak to make the container read-only
RUN mkdir -p /tmp/z-push/ && \
    for i in /etc/z-push/*; do \
        mv "$i" "$i.dist"; \
        ln -s /tmp/z-push/"$(basename "$i")" "$i"; \
    done

# ensure right permissions of folders (should have been taked care of by the packaging, just for good measure)
RUN \
    mkdir -p /var/lib/z-push /var/log/z-push && \
    chown www-data:www-data /var/lib/z-push /var/log/z-push

COPY kopano-z-push.conf /etc/php/7.3/fpm/pool.d/
COPY kweb.cfg /etc/kweb.cfg
COPY start.sh /kopano/start.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF
