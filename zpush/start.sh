#!/bin/bash

# define default value for serverhostname, serverport, additional packages and shared folders  if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-237}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
ZPUSH_ADDITIONAL_FOLDERS=${ZPUSH_ADDITIONAL_FOLDERS:-"[]"}

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

php_cfg_gen() {
	local cfg_file="$1"
	local cfg_setting="$2"
	local cfg_value="$3"
	if [ -e "$cfg_file" ]; then
		if grep -q "$cfg_setting" "$cfg_file"; then
			echo "Setting $cfg_setting = $cfg_value in $cfg_file"
			case $cfg_value in
			true|TRUE|false|FALSE)
				echo boolean value
				sed -ri "s#(\s*define).+${cfg_setting}.+#\tdefine(\x27${cfg_setting}\x27, ${cfg_value}\);#g" "$cfg_file"
				;;
			*)
				sed -ri "s#(\s*define).+${cfg_setting}.+#\tdefine(\x27${cfg_setting}\x27, \x27${cfg_value}\x27\);#g" "$cfg_file"
				;;
			esac
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

if [ "${AUTOCONFIGURE}" == true ]; then
	# Hint: this is not compatible with a read-only container.
	# The general recommendation is to already build a container that has all required packages installed.
	ADDITIONAL_KOPANO_PACKAGES=$(echo "$ADDITIONAL_KOPANO_PACKAGES" | tr -d '"')
	if mkdir -p "/var/lib/apt/lists/" 2&> /dev/null; then
		[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
		[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
			# shellcheck disable=SC2016 disable=SC2086
			if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
				DEBIAN_FRONTEND=noninteractive apt --assume-yes --no-upgrade install "$installpkg"
			else
				echo "INFO: $installpkg is already installed"
			fi
		done
	else
		echo "Notice: Container is run read-only, skipping package installation."
		echo "If you want to have additional packages installed in the container either:"
		echo "- build your own image with the packages already included"
		echo "- switch the container to 'read_only: false'"
	fi

	# copy latest config template
	mkdir -p /tmp/z-push/
	for i in /etc/z-push/*.dist; do
		filename=$(basename -- "$i")
		cp "$i" "/tmp/z-push/${filename%.*}"
	done

	# Ensure directories
	mkdir -p /run/sessions

	phpversion=$(dpkg-query --showformat='${Version}' --show php7-mapi)
	echo "Using PHP-Mapi: $phpversion"
	zpushversion=$(dpkg-query --showformat='${Version}' --show z-push-kopano)
	echo "Using Z-Push: $zpushversion"

	if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
		echo "Z-Push is using the default: connection"
	else
		echo "Z-Push is using an ip connection"
		php_cfg_gen /tmp/z-push/kopano.conf.php MAPI_SERVER "https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano"
	fi

	echo "Configuring Z-Push for use behind a reverse proxy"
	php_cfg_gen /tmp/z-push/z-push.conf.php USE_CUSTOM_REMOTE_IP_HEADER HTTP_X_FORWARDED_FOR

	# configuring z-push from env
	for setting in $(compgen -A variable KCCONF_ZPUSH_); do
		setting2=${setting#KCCONF_ZPUSH_}
		php_cfg_gen /tmp/z-push/z-push.conf.php "${setting2}" "${!setting}"
	done

	# configuring autodiscover
	for setting in $(compgen -A variable KCCONF_ZPUSHAUTODISCOVER_); do
		setting2=${setting#KCCONF_ZPUSHAUTODISCOVER_}
		php_cfg_gen /tmp/z-push/autodiscover.conf.php "${setting2}" "${!setting}"
	done

	# configuring z-push gabsync
	php_cfg_gen /tmp/z-push/gabsync.conf.php USERNAME SYSTEM

	for setting in $(compgen -A variable KCCONF_ZPUSHGABSYNC_); do
		setting2=${setting#KCCONF_ZPUSHGAVSYNC_}
		php_cfg_gen /tmp/z-push/z-push.conf.php "${setting2}" "${!setting}"
	done

	# configuring z-push sql state engine
	for setting in $(compgen -A variable KCCONF_ZPUSHSQL_); do
		setting2=${setting#KCCONF_ZPUSHSQL_}
		php_cfg_gen /tmp/z-push/state-sql.conf.php "${setting2}" "${!setting}"
	done

	# configuring z-push memcached
	for setting in $(compgen -A variable KCCONF_ZPUSHMEMCACHED_); do
		setting2=${setting#KCCONF_ZPUSHMEMCACHED_}
		php_cfg_gen /tmp/z-push/memcached.conf.php "${setting2}" "${!setting}"
	done

	# configuring z-push gab2contacts
	for setting in $(compgen -A variable KCCONF_ZPUSHGA2CONTACTS_); do
		setting2=${setting#KCCONF_ZPUSHSQL_}
		php_cfg_gen /tmp/z-push/gab2contacts.conf.php "${setting2}" "${!setting}"
	done

	# configuring z-push shared folders
	perl -i -0pe 's/\$additionalFolders.*\);//s' /tmp/z-push/z-push.conf.php
	echo -e "  \$additionalFolders = array(" >> /tmp/z-push/z-push.conf.php
	echo "$ZPUSH_ADDITIONAL_FOLDERS" | jq -c '.[]' | while read -r folder; do
		eval "$(echo "$folder" | jq -r '@sh "NAME=\(.name) ID=\(.id) TYPE=\(.type) FLAGS=\(.flags)"')"
		echo -e "    array('store' => \"SYSTEM\", 'folderid' => \"$ID\", 'name' => \"$NAME\", 'type' => $TYPE, 'flags' => $FLAGS)," >> /etc/z-push/z-push.conf.php
	done
	echo -e '  );' >> /tmp/z-push/z-push.conf.php

	echo "Ensure config ownership"
	chown -R www-data:www-data /run/sessions

	# services need to be aware of the machine-id
	#dockerize \
	#	-wait file:///etc/machine-id \
	#	-wait file:///var/lib/dbus/machine-id
fi

echo "Activate z-push log rerouting"
mkdir -p /var/log/z-push/
touch /var/log/z-push/{z-push.log,z-push-error.log,autodiscover.log,autodiscover-error.log}
chown -R www-data:www-data /var/log/z-push
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push-error.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/autodiscover.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/autodiscover-error.log &

set +u
# cleaning up env variables
unset "${!KCCONF_@}"
echo "Starting php-fpm"
php-fpm7.3 -F &
exec /usr/libexec/kopano/kwebd caddy -conf /etc/kweb.cfg
