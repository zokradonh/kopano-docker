# syntax = docker/dockerfile:1.0-experimental
ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base:latest

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DEBIAN_FRONTEND=noninteractive
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_MEET_VERSION=newest
ENV KOPANO_MEET_VERSION=$KOPANO_MEET_VERSION

ENV \
    ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES \
    KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION \
    SERVICE_TO_START=meet

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Meet container" \
    org.label-schema.description="Container for running Kopano Meet" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_MEET_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=secret,id=repocred,target=/etc/apt/auth.conf.d/kopano.conf \
    --mount=type=bind,target=/kopano/repo,source=/kopano/repo,from=zokradonh/kopano_repo_helper \
    --mount=type=bind,target=/etc/apt/sources.list.d/,source=/etc/apt/sources.list.d/,from=zokradonh/kopano_repo_helper \
    # install
    apt-get update && \
    # TODO mime-support could be remove once its an official dependency of kopano-kwebd
    apt-get install --no-install-recommends -y \
        mime-support \
        kopano-kwebd \
        kopano-meet kopano-meet-webapp \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    # make configuration a symlink to prevent overwriting it
    # TODO better would be to override its configuration in kweb.cfg
    mkdir -p /etc/kopano/kweb/overrides.d/config/kopano/ && \
    ln -s /tmp/meet.json /etc/kopano/kweb/overrides.d/config/kopano/meet.json

COPY start-service.sh /kopano/
COPY goss.yaml /goss/
CMD [ "/kopano/start-service.sh" ]

HEALTHCHECK --interval=1m --timeout=10s \
    CMD goss -g /goss/goss.yaml validate

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF