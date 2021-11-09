# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_php

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG ADDITIONAL_KOPANO_WEBAPP_PLUGINS=""
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_WEBAPP_VERSION=newest

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    ADDITIONAL_KOPANO_WEBAPP_PLUGINS=$ADDITIONAL_KOPANO_WEBAPP_PLUGINS \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
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
    --mount=type=bind,target=/kopano/repo,source=/kopano/repo,from=kopano_repo_helper \
    --mount=type=bind,target=/etc/apt/sources.list.d/,source=/etc/apt/sources.list.d/,from=kopano_repo_helper \
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