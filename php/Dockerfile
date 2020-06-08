# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

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
    org.label-schema.name="Kopano php container" \
    org.label-schema.description="Base container for running php based applications based on Kopano Groupware Core" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_CORE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# add install common php dependencies
# hadolint ignore=SC2215
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    # apt key for this repo has already been installed in base
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    # install
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        kopano-kwebd \
        php-fpm \
        crudini \
        ca-certificates \
        ${ADDITIONAL_KOPANO_PACKAGES} \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# configure php-fpm
RUN \
    mkdir -p /run/php && chown www-data:www-data /run/php && \
    crudini --set /etc/php/7.3/fpm/php.ini PHP upload_max_filesize 500M && \
    crudini --set /etc/php/7.3/fpm/php.ini PHP post_max_size 500M && \
    crudini --set /etc/php/7.3/fpm/php.ini PHP max_input_vars 1800 && \
    crudini --set /etc/php/7.3/fpm/php.ini Session session.save_path /run/sessions

EXPOSE 9080/tcp

COPY start-helper.sh /kopano/start-helper.sh
COPY kweb.cfg /etc/kweb.cfg

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF