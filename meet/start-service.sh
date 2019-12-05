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

# Populate app grid
# Note: if below variables are set to "no" kpop will fall back to its default behaviour and show all known apps.
# enable Kopano Konnect in the app grid
if [ "${GRID_KONNECT:-yes}" = "yes" ]; then
	jq '.apps.enabled += ["kopano-konnect"]' $CONFIG_JSON | sponge $CONFIG_JSON
fi

# enable Kopano Meet in the app grid
if [ "${GRID_MEET:-yes}" = "yes" ]; then
	jq '.apps.enabled += ["kopano-meet"]' $CONFIG_JSON | sponge $CONFIG_JSON
fi

# enable Kopano WebApp in the app grid
if [ "${GRID_WEBAPP:-yes}" = "yes" ]; then
	jq '.apps.enabled += ["kopano-webapp"]' $CONFIG_JSON | sponge $CONFIG_JSON
fi

sed -i s/\ *=\ */=/g /etc/kopano/kwebd.cfg
# always disable tls
export tls=no
# shellcheck disable=SC2046
export $(grep -v '^#' /etc/kopano/kwebd.cfg | xargs -d '\n')

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

# cleaning up env variables
unset "${!KCCONF_@}"
exec kopano-kwebd serve
