#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-236}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

# TODO this is not compatible with a read-only container
ADDITIONAL_KOPANO_PACKAGES=$(echo "$ADDITIONAL_KOPANO_PACKAGES" | tr -d '"')
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
	# shellcheck disable=SC2016 disable=SC2086
	if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
		apt --assume-yes --no-upgrade install "$installpkg"
	fi
done

echo "Ensure directories"
mkdir -p /run/sessions

CONFIG_PHP=/tmp/config.php
# copy latest config template. This should be the mount point for preexisting config files.
cp /usr/share/kdav/config.php.dist $CONFIG_PHP

if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
	echo "kDAV is using the default: connection"
else
	echo "kDAV is using an ip connection"
	sed -e "s#define([\"']MAPI_SERVER[\"'],\s*[\"']default:[\"'])#define('MAPI_SERVER', 'https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano')#" \
		-i $CONFIG_PHP
fi

# change root uri to /kdav
sed -e "s#define('DAV_ROOT_URI', '/');#define('DAV_ROOT_URI', '/kdav/');#" -i $CONFIG_PHP

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

touch /var/log/kdav/kdav.log
chown www-data:www-data /var/log/kdav/kdav.log
tail --pid=$$ -F --lines=0 -q /var/log/kdav/kdav.log &

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
# shellcheck disable=SC1091
source /etc/apache2/envvars
# cleaning up env variables
unset "${!KCCONF_@}"
exec /usr/sbin/apache2 -DFOREGROUND
