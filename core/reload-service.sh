#!/bin/bash

KCCONF_SERVER_MYSQL_SOCKET=${KCCONF_SERVER_MYSQL_SOCKET:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

if [ ! -e /kopano/"$SERVICE_TO_START".py ]; then
	echo "Invalid service specified: $SERVICE_TO_START" | ts
	exit 1
fi

echo "Configure core service '$SERVICE_TO_START'" | ts
/usr/bin/python3 /kopano/"$SERVICE_TO_START".py

# start regular service
case "$SERVICE_TO_START" in
server)
	# cleaning up env variables
	env
	unset "${!KCCONF_@}"
	env
	kill -HUP $(pidof kopano-server)
	;;
*)
	echo "Failed to start: Unhandled service name: '$SERVICE_TO_START'" | ts
	exit 1
esac
