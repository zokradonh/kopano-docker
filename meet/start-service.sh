#!/bin/bash

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

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
for setting in $(compgen -A variable KCCONF_MEET); do
	echo "Variable: $setting"
	setting2=${setting#KCCONF_MEET_}
	echo "Setting: $setting2"
	echo "Cleaned setting: ${setting2//_/.}"
	echo "Value: ${!setting}"
	jq ".\"${setting2//_/\".\"}\" = \"${!setting}\"" $CONFIG_JSON | sponge $CONFIG_JSON
done

jq . $CONFIG_JSON

sed -i s/\ *=\ */=/g /etc/kopano/kwebd.cfg
# shellcheck disable=SC2046
export $(grep -v '^#' /etc/kopano/kwebd.cfg | xargs -d '\n')
# cleaning up env variables
unset "${!KCCONF_@}"
exec kopano-kwebd serve

