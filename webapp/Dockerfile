ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG DEBIAN_FRONTEND=noninteractive

ARG ADDITIONAL_KOPANO_PACKAGES=""
ENV ADDITIONAL_KOPANO_PACKAGES=$ADDITIONAL_KOPANO_PACKAGES
ARG ADDITIONAL_KOPANO_WEBAPP_PLUGINS=""
ENV ADDITIONAL_KOPANO_WEBAPP_PLUGINS=$ADDITIONAL_KOPANO_WEBAPP_PLUGINS
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ENV DOWNLOAD_COMMUNITY_PACKAGES=$DOWNLOAD_COMMUNITY_PACKAGES
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ENV KOPANO_CORE_REPOSITORY_URL=$KOPANO_CORE_REPOSITORY_URL
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ENV KOPANO_REPOSITORY_FLAGS=$KOPANO_REPOSITORY_FLAGS
ARG KOPANO_WEBAPP_REPOSITORY_URL="file:/kopano/repo/webapp"
ENV KOPANO_WEBAPP_REPOSITORY_URL=$KOPANO_WEBAPP_REPOSITORY_URL
ARG KOPANO_WEBAPP_SMIME_REPOSITORY_URL="file:/kopano/repo/smime"
ENV KOPANO_WEBAPP_SMIME_REPOSITORY_URL=$KOPANO_WEBAPP_SMIME_REPOSITORY_URL
ARG KOPANO_WEBAPP_MDM_REPOSITORY_URL="file:/kopano/repo/mdm"
ENV KOPANO_WEBAPP_MDM_REPOSITORY_URL=$KOPANO_WEBAPP_MDM_REPOSITORY_URL
ARG KOPANO_WEBAPP_FILES_REPOSITORY_URL="file:/kopano/repo/files"
ENV KOPANO_WEBAPP_FILES_REPOSITORY_URL=$KOPANO_WEBAPP_FILES_REPOSITORY_URL
ARG KOPANO_CORE_VERSION=newest
ENV KOPANO_CORE_VERSION=$KOPANO_CORE_VERSION
ARG KOPANO_WEBAPP_VERSION=newest
ENV KOPANO_WEBAPP_VERSION=$KOPANO_WEBAPP_VERSION
ARG KOPANO_WEBAPP_FILES_VERSION=newest
ENV KOPANO_WEBAPP_FILES_VERSION=$KOPANO_WEBAPP_FILES_VERSION
ARG KOPANO_WEBAPP_MDM_VERSION=newest
ENV KOPANO_WEBAPP_MDM_VERSION=$KOPANO_WEBAPP_MDM_VERSION
ARG KOPANO_WEBAPP_SMIME_VERSION=newest
ENV KOPANO_WEBAPP_SMIME_VERSION=$KOPANO_WEBAPP_SMIME_VERSION
ARG RELEASE_KEY_DOWNLOAD=0
ENV RELEASE_KEY_DOWNLOAD=$RELEASE_KEY_DOWNLOAD

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install Kopano WebApp and refresh ca-certificates
# hadolint ignore=SC2129
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core"; \
        dl_and_package_community "webapp"; \
        dl_and_package_community "files"; \
        dl_and_package_community "mdm"; \
        dl_and_package_community "smime"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_SMIME_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_MDM_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_FILES_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    # save kopano version
    echo "core-${KOPANO_CORE_VERSION}" > /kopano/buildversion; \
    echo "webapp-${KOPANO_WEBAPP_VERSION}" >> /kopano/buildversion; \
    echo "files-${KOPANO_WEBAPP_FILES_VERSION}" >> /kopano/buildversion; \
    echo "mdm-${KOPANO_WEBAPP_MDM_VERSION}" >> /kopano/buildversion; \
    echo "smime-${KOPANO_WEBAPP_SMIME_VERSION}" >> /kopano/buildversion; \
    # install apt keys if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi; \
    # install
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        kopano-kwebd \
        php-fpm \
        crudini \
        ca-certificates \
        kopano-webapp \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        ${ADDITIONAL_KOPANO_WEBAPP_PLUGINS} \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# configure basics
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # configure php-fpm
    mkdir -p /run/php && chown www-data:www-data /run/php && \
    crudini --set /etc/php/7.0/fpm/php.ini PHP upload_max_filesize 500M && \
    crudini --set /etc/php/7.0/fpm/php.ini PHP post_max_size 500M && \
    crudini --set /etc/php/7.0/fpm/php.ini PHP max_input_vars 1800 && \
    crudini --set /etc/php/7.0/fpm/php.ini Session session.save_path /run/sessions

EXPOSE 80/tcp

COPY start.sh /kopano/start.sh
COPY kweb.cfg /etc/kweb.cfg

ENV LANG en_US.UTF-8

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]
