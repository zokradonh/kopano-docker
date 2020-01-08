#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-237}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
ADDITIONAL_KOPANO_WEBAPP_PLUGINS=${ADDITIONAL_KOPANO_WEBAPP_PLUGINS:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

# shellcheck source=php/start-helper.sh
source /kopano/start-helper.sh

# Hint: this is not compatible with a read-only container.
# The general recommendation is to already build a container that has all required packages installed.
ADDITIONAL_KOPANO_PACKAGES="$ADDITIONAL_KOPANO_PACKAGES $ADDITIONAL_KOPANO_WEBAPP_PLUGINS"
ADDITIONAL_KOPANO_PACKAGES=$(echo "$ADDITIONAL_KOPANO_PACKAGES" | tr -d '"')
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
	# shellcheck disable=SC2016 disable=SC2086
	if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
		DEBIAN_FRONTEND=noninteractive apt --assume-yes --no-upgrade install "$installpkg"
	else
		echo "INFO: $installpkg is already installed"
	fi
done

# copy latest config template.
for i in /etc/kopano/webapp/* /etc/kopano/webapp/.[^.]*; do \
        mv "$i" "$i.dist"; \
        ln -s /tmp/"$(basename $i)" "$i"; \
    done;

# Ensure directories exist
mkdir -p /run/sessions /tmp/webapp

phpversion=$(dpkg-query --showformat='${Version}' --show php7-mapi)
echo "Using PHP-Mapi: $phpversion"
webappversion=$(dpkg-query --showformat='${Version}' --show kopano-webapp)
echo "Using Kopano WebApp: $webappversion"

if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
	echo "Kopano WebApp is using the default: connection"
else
	echo "Kopano WebApp is using an ip connection"
	php_cfg_gen /etc/kopano/webapp/config.php DEFAULT_SERVER "https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano"
fi

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

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

set +u
# cleaning up env variables
unset "${!KCCONF_@}"
echo "Starting php-fpm"
php-fpm7.0 -F &
exec /usr/libexec/kopano/kwebd caddy -conf /etc/kweb.cfg
