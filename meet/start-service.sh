#!/bin/bash

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

if [ ! -e /kopano/"$SERVICE_TO_START".py ]; then
	echo "Invalid service specified: $SERVICE_TO_START" | ts
	exit 1
fi

echo "Configure service '$SERVICE_TO_START'" | ts
/usr/bin/python3 /kopano/"$SERVICE_TO_START".py

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

CONFIG_JSON="/usr/share/kopano-kweb/www/config/kopano/meet.json"
echo "Updating $CONFIG_JSON"
for setting in $(compgen -A variable KCCONF_MEET); do
	setting2=${setting#KCCONF_MEET_}
	# dots in setting2 need to be escaped to not be handled as separate entities in the json file
	case ${!setting} in
		true|TRUE|false|FALSE)
			jq ".\"${setting2//_/\".\"}\" = ${!setting}" $CONFIG_JSON | sponge $CONFIG_JSON
			;;
		*)
			jq ".\"${setting2//_/\".\"}\" = \"${!setting}\"" $CONFIG_JSON | sponge $CONFIG_JSON
			;;
		esac
done

# enable Kopano Konnect in the app grid
jq '.apps += {"enabled": ["kopano-konnect"]}' $CONFIG_JSON | sponge $CONFIG_JSON

# enable Kopano WebApp in the app grid (enabled by default)
# TODO how to only update the array?
if [ "${GRID_WEBAPP:-yes}" = "yes" ]; then
	jq '.apps += {"enabled": ["kopano-webapp", "kopano-konnect"]}' $CONFIG_JSON | sponge $CONFIG_JSON
fi

#cat $CONFIG_JSON

sed -i s/\ *=\ */=/g /etc/kopano/kwebd.cfg
export tls=no
# shellcheck disable=SC2046
export $(grep -v '^#' /etc/kopano/kwebd.cfg | xargs -d '\n')
# cleaning up env variables
unset "${!KCCONF_@}"
exec kopano-kwebd serve
