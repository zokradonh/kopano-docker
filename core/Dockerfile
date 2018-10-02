FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="2.0"

RUN mkdir -p /kopano/repo /kopano/data
WORKDIR /kopano/repo

ARG DEBIAN_FRONTEND=noninteractive

# install basics
RUN apt-get update && \
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
ARG KOPANO_REPOSITORY_BRANCH=master
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo"
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG RELEASE_KEY_DOWNLOAD=0
ARG ADDITIONAL_KOPANO_PACKAGES

# community build
COPY download_community.sh /kopano/download_community.sh

RUN \
    # community download 
    [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ] && \
    chmod a+x /kopano/download_community.sh && \
    /kopano/download_community.sh core && \
    gzip -f9 Packages; \
    # install
    set -x && \
    echo ${KOPANO_CORE_VERSION} > /kopano/buildversion && \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano-core.list; \
    [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ] && curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        kopano-server-packages="${KOPANO_CORE_VERSION}" \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        php7.0-cli && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    cp /usr/share/doc/kopano/example-config/*.cfg /etc/kopano/ && \
    cp /usr/share/doc/kopano/example-config/*.cfg.gz /etc/kopano/ && \
    gzip -d -f /etc/kopano/*.gz

ENV KOPANO_LOCALE="de_DE.UTF-8"
ENV KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8"
ENV LANG=en_US.UTF-8 

ENV SERVICE_TO_START=server

COPY kcconf.py defaultconfigs/ start-service.sh /kopano/
RUN chmod a+x /kopano/start-service.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD [ "/kopano/start-service.sh" ]