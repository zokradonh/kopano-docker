# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM composer:1.9 as builder

RUN git clone --depth 1 https://stash.kopano.io/scm/kc/kdav.git /usr/share/kopano-kdav
WORKDIR /usr/share/kopano-kdav
RUN composer install

FROM ${docker_repo}/kopano_php

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES \
    KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano kDAV container" \
    org.label-schema.description="Container for running Kopano kDAV" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.schema-version="1.0"

# install Kopano kDAV
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        php-mbstring \
        php-xml \
        php-zip \
        sqlite \
        php-sqlite3 \
        unzip \
        ${ADDITIONAL_KOPANO_PACKAGES} \
    && rm -rf /var/cache/apt /var/lib/apt/lists/*

# ensure right permissions of folders
RUN \
    mkdir -p /var/lib/kopano/kdav /var/log/kdav && \
    chown www-data:www-data /var/lib/kopano/kdav /var/log/kdav

COPY --from=builder /usr/share/kopano-kdav /usr/share/kopano-kdav

# tweaks to make the container read-only
RUN \
    mv /usr/share/kopano-kdav/config.php /usr/share/kopano-kdav/config.php.dist && \
    ln -s /tmp/config.php /usr/share/kopano-kdav/config.php

COPY kopano-kdav.conf /etc/php/7.3/fpm/pool.d/
COPY start.sh /kopano/start.sh
COPY kweb.cfg /etc/kweb.cfg

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF
