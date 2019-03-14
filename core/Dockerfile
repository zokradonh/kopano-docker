ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG DEBIAN_FRONTEND=noninteractive

ARG ADDITIONAL_KOPANO_PACKAGES=""
ENV ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ENV DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ENV KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL
ARG KOPANO_CORE_VERSION=newest
ENV KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ENV KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS
ARG RELEASE_KEY_DOWNLOAD=0
ENV RELEASE_KEY_DOWNLOAD=$RELEASE_KEY_DOWNLOAD

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano Core and refresh ca-certificates
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    # save kopano version
    echo "core-${KOPANO_CORE_VERSION}" > /kopano/buildversion; \
    # install apt key if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi; \
    # install
    apt-get update && \
    set -x && \
    apt-get install --no-install-recommends -y \
        kopano-server-packages \
	kopano-grapi kopano-kapid \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        && \
    set +x && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    touch /etc/kopano/admin.cfg && \
    cp /usr/share/doc/kopano/example-config/*.cfg /etc/kopano/ && \
    cp /usr/share/doc/kopano/example-config/*.cfg.gz /etc/kopano/ && \
    gzip -d -f /etc/kopano/*.gz

ENV KOPANO_LOCALE="de_DE.UTF-8"
ENV KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8"
ENV LANG=en_US.UTF-8

ENV SERVICE_TO_START=server

COPY defaultconfigs/ start-service.sh /kopano/
COPY services /kopano/services

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD [ "/kopano/start-service.sh" ]

HEALTHCHECK --interval=5m --timeout=60s \
	CMD /kopano/healthcheck.sh
