FROM zokradonh/kopano_common AS common

FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="2.0"

RUN mkdir -p /kopano/repo /kopano/data /kopano/helper
WORKDIR /kopano/repo

ARG DEBIAN_FRONTEND=noninteractive

# install basics
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        curl \
        gpg \
        ca-certificates \
        moreutils \
        locales \
        apt-transport-https \
        apt-utils jq \
        dumb-init \
        python3-minimal && \
    rm -rf /var/cache/apt /var/lib/apt/lists

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG RELEASE_KEY_DOWNLOAD=0
ARG ADDITIONAL_KOPANO_PACKAGES=""

# get common utilities
COPY --from=common /common.sh /kopano/helper/

SHELL [ "/bin/bash", "-c"]

RUN \
    # community download and package as apt source repository
    . /kopano/helper/common.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    # save kopano version if supported kopano
    if [ ! -f /kopano/buildversion ]; then \
        echo "core-${KOPANO_CORE_VERSION}" > /kopano/buildversion; \
    fi; \
    # install apt key if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi; \
    # install
    apt-get update && \
    set -x && \
    apt-get install --no-install-recommends -y \
        kopano-server-packages \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        php7.0-cli && \
    set +x && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    cp /usr/share/doc/kopano/example-config/*.cfg /etc/kopano/ && \
    cp /usr/share/doc/kopano/example-config/*.cfg.gz /etc/kopano/ && \
    gzip -d -f /etc/kopano/*.gz

ENV KOPANO_LOCALE="de_DE.UTF-8"
ENV KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8"
ENV LANG=en_US.UTF-8

ENV SERVICE_TO_START=server

COPY kcconf.py defaultconfigs/ start-service.sh /kopano/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD [ "/kopano/start-service.sh" ]
