FROM debian:buster

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0

# Both UID and GID should not be set to values above 999
ARG KOPANO_UID=999
ARG KOPANO_GID=999

ENV \
    BASE_VERSION=2.1.0 \
    DEBIAN_FRONTEND=noninteractive \
    DEBUG=""

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano base container" \
    org.label-schema.description="Base image for containers running the Kopano groupware stack" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$BASE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p /kopano/repo /kopano/data /kopano/helper /kopano/path
WORKDIR /kopano/repo

# install basics
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        dumb-init \
        gpg \
        gpg-agent \
        jq \
        locales \
        moreutils \
        python3-minimal \
        && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

# Create kopano user and group
RUN groupadd --system --gid ${KOPANO_GID} kopano
RUN useradd --system --shell /usr/sbin/nologin --home /var/lib/kopano --gid ${KOPANO_GID} --uid ${KOPANO_UID} kopano

ENV DOCKERIZE_VERSION v0.11.6
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-"$(uname -s)"-"$(uname -m)" \
    | install /dev/stdin /usr/local/bin/dockerize && \
    dockerize --version

ENV GOSS_VERSION v0.3.11
RUN curl -L https://github.com/aelsabbahy/goss/releases/download/$GOSS_VERSION/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +rx /usr/local/bin/goss && \
    goss --version

# if additional locales are required this should be adjusted here
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# get common utilities
COPY create-kopano-repo.sh /kopano/helper/
COPY kcconf.py Release.key defaultconfigs/ /kopano/
RUN apt-key add /kopano/Release.key

SHELL [ "/bin/bash", "-c"]

ONBUILD ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ONBUILD ARG DOWNLOAD_DISTRIBUTION="Debian_10"
ONBUILD ARG DOWNLOAD_CHANNEL="community"
ONBUILD ARG DOWNLOAD_BRANCH=""
ONBUILD RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"; \
    fi

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF