#!/bin/bash

# define default value for serverhostname and serverport if not passed into container
KCCONF_SERVERHOSTNAME=${KCCONF_SERVERHOSTNAME:-127.0.0.1}
KCCONF_SERVERPORT=${KCCONF_SERVERPORT:-236}
ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

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

[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
	# shellcheck disable=SC2016 disable=SC2086
	if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
		apt --assume-yes install "$installpkg"
	fi
done

# Ensure directories
mkdir -p /run/sessions

if [ "$KCCONF_SERVERHOSTNAME" == "127.0.0.1" ]; then
	echo "Z-Push is using the default: connection"
else
	echo "Z-Push is using an ip connection"
	php_cfg_gen /etc/z-push/kopano.conf.php MAPI_SERVER "https://${KCCONF_SERVERHOSTNAME}:${KCCONF_SERVERPORT}/kopano"
fi

echo "Configuring Z-Push for use behind a reverse proxy"
php_cfg_gen /etc/z-push/z-push.conf.php USE_CUSTOM_REMOTE_IP_HEADER HTTP_X_FORWARDED_FOR

# configuring z-push from env
for setting in $(compgen -A variable KCCONF_WEBAPP_); do
	setting2=${setting#KCCONF_ZPUSH_}
	php_cfg_gen /etc/z-push/z-push.conf.php "${setting2}" "${!setting}"
done

php_cfg_gen /etc/z-push/gabsync.conf.php USERNAME SYSTEM
# configuring z-push gabsync from env
for setting in $(compgen -A variable KCCONF_WEBAPP_); do
	setting2=${setting#KCCONF_ZPUSHGABSYNC_}
	php_cfg_gen /etc/z-push/z-push.conf.php "${setting2}" "${!setting}"
done

echo "Ensure config ownership"
chown -R www-data:www-data /run/sessions

echo "Activate z-push log rerouting"
touch /var/log/z-push/z-push.log
touch /var/log/z-push/z-push-error.log
chown www-data:www-data /var/log/z-push/z-push.log /var/log/z-push/z-push-error.log
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push.log &
tail --pid=$$ -F --lines=0 -q /var/log/z-push/z-push-error.log &

echo "Starting Apache"
rm -f /run/apache2/apache2.pid
set +u
# shellcheck disable=SC1091
source /etc/apache2/envvars
# cleaning up env variables
unset "${!KCCONF_@}"
exec /usr/sbin/apache2 -DFOREGROUND
