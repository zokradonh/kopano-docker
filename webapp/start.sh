#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-237}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
ADDITIONAL_KOPANO_WEBAPP_PLUGINS=${ADDITIONAL_KOPANO_WEBAPP_PLUGINS:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

ADDITIONAL_KOPANO_PACKAGES="$ADDITIONAL_KOPANO_PACKAGES $ADDITIONAL_KOPANO_WEBAPP_PLUGINS"

[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
	# shellcheck disable=SC2016 disable=SC2086
	if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
		apt --assume-yes install "$installpkg"
	fi
done

# Ensure directories exist
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

# configuring webapp from env
for setting in $(compgen -A variable KCCONF_WEBAPP_); do
	setting2=${setting#KCCONF_WEBAPP_}
	echo "Setting ${setting2} = ${!setting} in config.php"
	sed -ri "s/(\s*define).+${setting2}.+/\1\(\x27${setting2}\x27, \x27${!setting}\x27\);/g" /etc/kopano/webapp/config.php
done

# configuring webapp plugins from env
for setting in $(compgen -A variable KCCONF_WEBAPPPLUGIN_); do
	setting2=${setting#KCCONF_WEBAPPPLUGIN_}
	filename="${setting2%%_*}"
	setting3=${setting#KCCONF_WEBAPPPLUGIN_${filename}_}
	identifier="${filename,,}"
	echo "Setting ${setting3} = ${!setting} in config-$identifier.php"
	if [ -e /etc/kopano/webapp/config-"$identifier".php ]; then
		sed -ri "s/(\s*define).+${setting3}.+/\1\(\x27${setting3}\x27, \x27${!setting}\x27\);/g" /etc/kopano/webapp/config-"$identifier".php
	else
		echo "The $identifier plugin does not seem to be installed!"
	fi
done

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions /tmp/webapp

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
# shellcheck disable=SC1091
source /etc/apache2/envvars
# cleaning up env variables
unset "${!KCCONF_@}"
exec /usr/sbin/apache2 -DFOREGROUND
