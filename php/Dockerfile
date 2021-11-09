# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_KAPPS_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano php container" \
    org.label-schema.description="Base container for running php based applications based on Kopano Groupware Core" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_CORE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# add install common php dependencies
RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    --mount=type=bind,target=/kopano/repo,source=/kopano/repo,from=kopano_repo_helper \
    --mount=type=bind,target=/etc/apt/sources.list.d/,source=/etc/apt/sources.list.d/,from=kopano_repo_helper \
    # install
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        crudini \
        kopano-kwebd \
        php-fpm \
        php7-mapi \
        ${ADDITIONAL_KOPANO_PACKAGES} \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# configure php-fpm
RUN \
    mkdir -p /run/php && chown www-data:www-data /run/php && \
    crudini --set /etc/php/7.3/fpm/php.ini Session session.save_path /run/sessions

EXPOSE 9080/tcp

COPY php-fpm.conf /etc/php/7.3/fpm/pool.d/
COPY start-helper.sh /kopano/start-helper.sh
COPY kweb.cfg /etc/kweb.cfg

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF