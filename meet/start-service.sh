#!/bin/bash

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

if [ ! -e /kopano/$SERVICE_TO_START.py ]; then
	echo "Invalid service specified: $SERVICE_TO_START" | ts
	exit 1
fi

echo "Configure core service '$SERVICE_TO_START'" | ts
/usr/bin/python3 /kopano/$SERVICE_TO_START.py

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

# cleaning up env variables
unset "${!KCCONF_@}"
export tls=false
exec kopano-kwebd serve

