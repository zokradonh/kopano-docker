FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="2.0"

RUN mkdir -p /kopano/repo /kopano/data /kopano/helper /kopano/path
WORKDIR /kopano/repo

ARG DEBIAN_FRONTEND=noninteractive

# install basics
# TODO require python3 or python3-minimal?
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
        python3 \
        && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzvf - -C /usr/local/bin

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0

# get common utilities
COPY create-kopano-repo.sh /kopano/helper/
COPY kcconf.py /kopano/
RUN date +%s > /kopano/buildversion

SHELL [ "/bin/bash", "-c"]
