ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base:latest

ARG DEBIAN_FRONTEND=noninteractive

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_MEET_REPOSITORY_URL="file:/kopano/repo/meet"
ARG KOPANO_MEET_VERSION=newest
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG RELEASE_KEY_DOWNLOAD=0

# install Kopano Core and refresh ca-certificates
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "meet"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_MEET_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    # save kopano version
    echo "meet-${KOPANO_MEET_VERSION}" > /kopano/buildversion; \
    # install apt key if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_MEET_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi; \
    # install
    apt-get update && \
    set -x && \
    apt-get install --no-install-recommends -y \
        kopano-kwebd \
	kopano-meet kopano-meet-webapp \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        && \
    cp /usr/share/doc/kopano-meet-webapp/config.json.in /usr/share/kopano-kweb/www/config/kopano/meet.json && \
    set +x && \
    rm -rf /var/cache/apt /var/lib/apt/lists

ENV KOPANO_LOCALE="de_DE.UTF-8"
ENV KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8"
ENV LANG=en_US.UTF-8

COPY defaultconfigs/ start-service.sh /kopano/
CMD [ "/kopano/start-service.sh" ]
