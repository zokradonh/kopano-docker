#!/bin/bash

set -eu # unset variables are errors & non-zero return values exit the whole script

echo "Ensure directories"
mkdir -p /run/sessions /tmp/webapp 

echo "Configure webapp"
sed -e "s#define(\"DEFAULT_SERVER\",\s*\".*\"#define(\"DEFAULT_SERVER\", \"https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano\"#" \
    -e "s#define(\"INSECURE_COOKIES\",\s*.*)#define(\"INSECURE_COOKIES\", true)#" \
    -i /etc/kopano/webapp/config.php

echo "Configure z-push"
sed -e "s#define([\"']MAPI_SERVER[\"'],\s*[\"']default:[\"'])#define('MAPI_SERVER', 'https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano')#" \
        -i /etc/z-push/kopano.conf.php
sed -e "s#define([\"']USE_X_FORWARDED_FOR_HEADER[\"'],\s*false)#define('USE_X_FORWARDED_FOR_HEADER', true)#" \
        -i /etc/z-push/z-push.conf.php

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions /tmp/webapp

echo "Activate z-push log rerouting"
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push-error.log &

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
#exec /bin/bash -c "source /etc/apache2/envvars && /usr/sbin/apache2 -DFOREGROUND"
