#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-237}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
ADDITIONAL_KOPANO_WEBAPP_PLUGINS=${ADDITIONAL_KOPANO_WEBAPP_PLUGINS:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

php_cfg_gen() {
	local cfg_file="$1"
	local cfg_setting="$2"
	local cfg_value="$3"
	if [ -e "$cfg_file" ]; then
		if grep -q "$cfg_setting" "$cfg_file"; then
			echo "Setting $cfg_setting = $cfg_value in $cfg_file"
			sed -ri "s/(\s*define).+${cfg_setting}.+/\1\(\x27${cfg_setting}\x27, \x27${cfg_value}\x27\);/g" "$cfg_file"
		else
			echo "Error: Config option $cfg_setting not found in $cfg_file"
			cat "$cfg_file"
			exit 1
		fi
		else
		echo "Error: Config file $cfg_file not found. Plugin not installed?"
		local dir
		dir=$(dirname "$cfg_file")
		ls -la "$dir"
		exit 1
	fi
}

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
	php_cfg_gen /etc/kopano/webapp/config.php "${setting2}" "${!setting}"
done

# configuring webapp plugins from env
for setting in $(compgen -A variable KCCONF_WEBAPPPLUGIN_); do
	setting2=${setting#KCCONF_WEBAPPPLUGIN_}
	filename="${setting2%%_*}"
	setting3=${setting#KCCONF_WEBAPPPLUGIN_${filename}_}
	identifier="${filename,,}"
	php_cfg_gen /etc/kopano/webapp/config-"$identifier".php "${setting3}" "${!setting}"
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
