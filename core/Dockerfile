FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="2.0"

RUN mkdir -p /kopano/repo /kopano/data
WORKDIR /kopano/repo

ENV DEBIAN_FRONTEND noninteractive

# install basics
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        curl \
        gpg \
        ca-certificates \
        moreutils \
        locales \
        apt-transport-https \
        python3 && \
    rm -rf /var/cache/apt /var/lib/apt/lists

RUN curl -s -S -L -o /usr/local/bin/confix https://raw.githubusercontent.com/budhash/confix/master/confix && \
    chmod +x /usr/local/bin/confix && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    curl -s -S -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod a+x /usr/local/bin/dumb-init

# If you have active Kopano subscription you can change KOPANO_CORE_REPOSITORY_URL to
# https://serial:<YOURSERIAL>@download.kopano.io/supported/core:/final/Debian_9.0
# and replace <YOURSERIAL> with your serial. You can also use pre-final or any other repository branch.
# If you want to use community version please use images from hub.docker.com
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_REPOSITORY_BRANCH=master
ARG KOPANO_CORE_REPOSITORY_URL="http://buildproxy/supported/core:/${KOPANO_REPOSITORY_BRANCH}/Debian_9.0"
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG NO_RELEASE_KEY_DOWNLOAD=0

# install kopano components
RUN set -x && \
    echo ${KOPANO_CORE_VERSION} > /kopano/buildversion && \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano-core.list; \
    (exit ${NO_RELEASE_KEY_DOWNLOAD}) && curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        kopano-server-packages="${KOPANO_CORE_VERSION}" \
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

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

CMD [ "/kopano/start-service.sh" ]