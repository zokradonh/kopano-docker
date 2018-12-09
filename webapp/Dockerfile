ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_base

ARG DEBIAN_FRONTEND=noninteractive

ARG ADDITIONAL_KOPANO_PACKAGES=""
ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG KOPANO_WEBAPP_REPOSITORY_URL="file:/kopano/repo/webapp"
ARG KOPANO_SMIME_REPOSITORY_URL="file:/kopano/repo/smime"
ARG KOPANO_CORE_VERSION=newest
ARG KOPANO_WEBAPP_VERSION=newest
ARG KOPANO_SMIME_VERSION=newest
ARG RELEASE_KEY_DOWNLOAD=0

# install Kopano WebApp and refresh ca-certificates
RUN \
    # community download and package as apt source repository
    . /kopano/helper/create-kopano-repo.sh && \
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then \
        dl_and_package_community "core"; \
        dl_and_package_community "webapp"; \
        dl_and_package_community "smime"; \
    fi; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./" > /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    echo "deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_SMIME_REPOSITORY_URL} ./" >> /etc/apt/sources.list.d/kopano.list; \
    # save kopano version
    echo "core-${KOPANO_CORE_VERSION}" > /kopano/buildversion; \
    echo "webapp-${KOPANO_WEBAPP_VERSION}" >> /kopano/buildversion; \
    echo "smime-${KOPANO_SMIME_VERSION}" >> /kopano/buildversion; \
    # install apt keys if supported kopano
    if [ ${RELEASE_KEY_DOWNLOAD} -eq 1 ]; then \
        curl -s -S -o - "${KOPANO_CORE_REPOSITORY_URL}/Release.key" | apt-key add -; \
    fi; \
    # install
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-php7.0 \
        crudini \
        ca-certificates \
        kopano-webapp \
        kopano-webapp-plugin-contactfax \
        kopano-webapp-plugin-desktopnotifications \
        kopano-webapp-plugin-filepreviewer \
        kopano-webapp-plugin-folderwidgets \
        kopano-webapp-plugin-gmaps \
        kopano-webapp-plugin-intranet \
        kopano-webapp-plugin-mattermost \
        kopano-webapp-plugin-pimfolder \
        kopano-webapp-plugin-quickitems \
        kopano-webapp-plugin-spell-de-at \
        kopano-webapp-plugin-spell-de-at \
        kopano-webapp-plugin-spell-de-ch \
        kopano-webapp-plugin-spell-de-de \
        kopano-webapp-plugin-spell-de-de \
        kopano-webapp-plugin-spell-en-gb \
        kopano-webapp-plugin-spell-en \
        kopano-webapp-plugin-spell-en \
        kopano-webapp-plugin-spell-es \
        kopano-webapp-plugin-spell-es \
        kopano-webapp-plugin-spell-fr \
        kopano-webapp-plugin-spell-it \
        kopano-webapp-plugin-spell-nl \
        kopano-webapp-plugin-spell-nl \
        kopano-webapp-plugin-spell-pl-pl \
        kopano-webapp-plugin-spell \
        kopano-webapp-plugin-spell \
        kopano-webapp-plugin-titlecounter \
        kopano-webapp-plugin-webappmanual \
        kopano-webapp-plugin-zdeveloper \
        kopano-webapp-plugin-smime \
        ${ADDITIONAL_KOPANO_PACKAGES} \
        whatsapp4deskapp \
    && rm -rf /var/cache/apt /var/lib/apt/lists

COPY apache2-kopano.conf /etc/apache2/sites-available/kopano.conf

# configure basics
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # configure apache
    rm /etc/apache2/sites-enabled/* && \
    sed -e 's,^ErrorLog.*,ErrorLog "|/bin/cat",' -i /etc/apache2/apache2.conf && \
    sed -e "s,MaxSpareServers[^:].*,MaxSpareServers 5," -i /etc/apache2/mods-available/mpm_prefork.conf && \
    a2disconf other-vhosts-access-log && \
    a2ensite kopano kopano-webapp && \
    echo "Listen 80" > /etc/apache2/ports.conf && \
    # configure mod_php
    a2enmod rewrite && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP upload_max_filesize 500M && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP post_max_size 500M && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP max_input_vars 1800 && \
    crudini --set /etc/php/7.0/apache2/php.ini Session session.save_path /run/sessions

EXPOSE 80/tcp

COPY start.sh /kopano/start.sh

ENV LANG en_US.UTF-8

WORKDIR /kopano/path

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]
