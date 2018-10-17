#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-237}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

[ ! -z "$ADDITIONAL_KOPANO_PACKAGES" ] && apt update
[ ! -z "$ADDITIONAL_KOPANO_PACKAGES" ] && for installpkg in "$ADDITIONAL_KOPANO_PACKAGES"; do
	if [ $(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		apt --assume-yes install $installpkg;
	fi
done

echo "Ensure directories"
mkdir -p /run/sessions /tmp/webapp

if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
	echo "Kopano WebApp is using the default: connection"
else
	echo "Kopano WebApp is using an ip connection"
	sed -e "s#define(\"DEFAULT_SERVER\",\s*\".*\"#define(\"DEFAULT_SERVER\", \"https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano\"#" \
	    -i /etc/kopano/webapp/config.php
fi

# TODO is enabling this really neccesary when reverse proxying webapp?
echo "Configuring Kopano WebApp for use behind a reverse proxy"
sed \
    -e "s#define(\"INSECURE_COOKIES\",\s*.*)#define(\"INSECURE_COOKIES\", true)#" \
    -i /etc/kopano/webapp/config.php

if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
	echo "Z-Push is using the default: connection"
else
	echo "Z-Push is using an ip connection"
	sed -e "s#define([\"']MAPI_SERVER[\"'],\s*[\"']default:[\"'])#define('MAPI_SERVER', 'https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano')#" \
	    -i /etc/z-push/kopano.conf.php
fi

echo "Configuring Z-Push for use behind a reverse proxy"
sed -e "s#define([\"']USE_CUSTOM_REMOTE_IP_HEADER[\"'],\s*false)#define('USE_CUSTOM_REMOTE_IP_HEADER', true)#" \
    -i /etc/z-push/z-push.conf.php

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions /tmp/webapp

echo "Activate z-push log rerouting"
touch /var/log/z-push/z-push.log
touch /var/log/z-push/z-push-error.log
chown www-data:www-data /var/log/z-push/z-push.log /var/log/z-push/z-push-error.log
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push-error.log &

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
