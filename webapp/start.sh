#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-236}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
ADDITIONAL_KOPANO_WEBAPP_PLUGINS=${ADDITIONAL_KOPANO_WEBAPP_PLUGINS:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

ADDITIONAL_KOPANO_PACKAGES="$ADDITIONAL_KOPANO_PACKAGES $ADDITIONAL_KOPANO_WEBAPP_PLUGINS"

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

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions /tmp/webapp

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
source /etc/apache2/envvars
# cleaning up env variables
unset "${!KCCONF_@}"
exec /usr/sbin/apache2 -DFOREGROUND
