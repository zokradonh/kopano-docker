ARG docker_repo=zokradonh
FROM composer:1.8 as builder

RUN git clone --depth 1 https://stash.kopano.io/scm/kc/kdav.git /usr/share/kdav
WORKDIR /usr/share/kdav
RUN composer install

FROM ${docker_repo}/kopano_php

ARG VCS_REF
ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS \
    RELEASE_KEY_DOWNLOAD=$RELEASE_KEY_DOWNLOAD

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano kDAV container" \
    org.label-schema.description="Container for running Kopano kDAV" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.schema-version="1.0"

# install Kopano kDAV and refresh ca-certificates
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        php-mbstring \
        php-sqlite3 \
        php-xml \
        php-zip \
        php7-mapi \
        sqlite \
        unzip \
        ${ADDITIONAL_KOPANO_PACKAGES} \
    && rm -rf /var/cache/apt /var/lib/apt/lists/*

# configure basics
RUN \
    mkdir -p /var/lib/kopano/kdav && \
    chown www-data:www-data /var/lib/kopano/kdav && \
    mkdir -p /var/log/kdav && \
    chown www-data:www-data /var/log/kdav

COPY --from=builder /usr/share/kdav /usr/share/kdav
COPY kweb.cfg /etc/kweb.cfg

EXPOSE 9080/tcp

COPY start.sh /kopano/start.sh

ENV LANG en_US.UTF-8

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]
