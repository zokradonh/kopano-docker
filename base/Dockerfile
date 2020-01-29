FROM debian:stretch

ARG VCS_REF
ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0

ARG KOPANO_UID=999
ARG KOPANO_GID=999

ENV \
    BASE_VERSION=1.3.0 \
    DEBUG="" \
    DEBIAN_FRONTEND=noninteractive

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
RUN apt-get update && \
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

# Create kopano user and group
RUN groupadd --system --gid ${KOPANO_GID} kopano
RUN useradd --system --shell /usr/sbin/nologin --home /var/lib/kopano --gid ${KOPANO_GID} --uid ${KOPANO_UID} kopano

ENV DOCKERIZE_VERSION v0.11.0
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-"$(uname -s)"-"$(uname -m)" \
    | install /dev/stdin /usr/local/bin/dockerize && \
    dockerize --version

ENV GOSS_VERSION v0.3.7
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
COPY kcconf.py /kopano/

SHELL [ "/bin/bash", "-c"]
