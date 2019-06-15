FROM debian:stretch

ARG VCS_REF
ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0
ARG DEBIAN_FRONTEND=noninteractive

ENV BASE_VERSION=1.2.0

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano base container" \
    org.label-schema.description="Base image for containers running the Kopano groupware stack" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$BASE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p /kopano/repo /kopano/data /kopano/helper /kopano/path
WORKDIR /kopano/repo

# install basics
# hadolint ignore=DL3005
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        dumb-init \
        gpg \
        jq \
        locales \
        moreutils \
        python3-minimal \
        && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*; \
    # install apt key if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi

ENV DOCKERIZE_VERSION v0.6.1
RUN curl -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzvf - -C /usr/local/bin

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# get common utilities
COPY create-kopano-repo.sh /kopano/helper/
COPY kcconf.py /kopano/

SHELL [ "/bin/bash", "-c"]
