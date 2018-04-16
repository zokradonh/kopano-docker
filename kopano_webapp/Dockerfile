FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="1.1"

RUN mkdir -p /kopano/repo && mkdir -p /kopano/data
WORKDIR /kopano/repo

ADD z-push-GPG.key /kopano/repo

ENV DEBIAN_FRONTEND noninteractive

ARG KOPANO_REPOSITORY=http://localhost:8081/kopanoarchive/

RUN apt-get update && \
    apt-get install -y curl crudini gpg && \
    echo "deb [trusted=yes] ${KOPANO_REPOSITORY} ./" > /etc/apt/sources.list.d/kopano.list; \
    echo "deb http://repo.z-hub.io/z-push:/final/Debian_9.0/ /" > /etc/apt/sources.list.d/zpush.list; \
    apt-key add /kopano/repo/z-push-GPG.key && \
    apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php7.0 \
    z-push-backend-kopano \
    z-push-config-apache \
    && rm -rf /var/cache/apt /var/lib/apt/lists

# trigger rebuild from here on new version - dont use cache my dear docker
ARG WEBAPP_VERSION

# install kopano web app and refresh ca-certificates
RUN echo ${WEBAPP_VERSION} > /kopano/buildversion && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    kopano-webapp \
    kopano-webapp-plugin-contactfax \
    kopano-webapp-plugin-desktopnotifications \
    kopano-webapp-plugin-filepreviewer \
    kopano-webapp-plugin-folderwidgets \
#    kopano-webapp-plugin-gmaps \
    kopano-webapp-plugin-pimfolder \
    kopano-webapp-plugin-quickitems \
#    kopano-webapp-plugin-spell-de-at \
#    kopano-webapp-plugin-spell-de-ch \
    kopano-webapp-plugin-spell-de-de \
    kopano-webapp-plugin-spell-en-gb \
    kopano-webapp-plugin-spell-en \
#    kopano-webapp-plugin-spell-es \
#    kopano-webapp-plugin-spell-fr \
#    kopano-webapp-plugin-spell-nl \
#    kopano-webapp-plugin-spell-pl-pl \
    kopano-webapp-plugin-spell \
#    kopano-webapp-plugin-titlecounter \
#    kopano-webapp-plugin-webappmanual \
#    kopano-webapp-plugin-zdeveloper \
    && rm -rf /var/cache/apt /var/lib/apt/lists

ADD apache2-kopano.conf /etc/apache2/sites-available/kopano.conf

    # configure basics
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod a+x /usr/local/bin/dumb-init && \
    # configure apache
    rm /etc/apache2/sites-enabled/* && \
    sed -e 's,^ErrorLog.*,ErrorLog "|/bin/cat",' -i /etc/apache2/apache2.conf && \
    sed -e "s,MaxSpareServers[^:].*,MaxSpareServers 5," -i /etc/apache2/mods-available/mpm_prefork.conf && \
    a2disconf other-vhosts-access-log && \
    a2ensite kopano && \
    echo "Listen 80" > /etc/apache2/ports.conf && \
    # configure mod_php
    a2enmod rewrite && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP upload_max_filesize 500M && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP post_max_size 500M && \
    crudini --set /etc/php/7.0/apache2/php.ini PHP max_input_vars 1800 && \
    crudini --set /etc/php/7.0/apache2/php.ini Session session.save_path /run/sessions && \
    # configure z-push
    mkdir -p /var/lib/z-push /var/log/z-push && \
    chown www-data:www-data /var/lib/z-push /var/log/z-push

VOLUME /var/lib/z-push/

EXPOSE 80/tcp

ADD start.sh /kopano/start.sh

RUN chmod a+x /kopano/start.sh

ENV LANG en_US.UTF-8 

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD [ "/kopano/start.sh" ]