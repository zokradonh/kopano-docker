#!/bin/bash

set -eu # unset variables are errors & non-zero return values exit the whole script

if [ ! -e /kopano/$SERVICE_TO_START.py ]
then
    echo "Invalid service specified: $SERVICE_TO_START" | ts
    exit 1
fi

mkdir -p /kopano/data/attachments /tmp/$SERVICE_TO_START /var/run/kopano

echo "Configure core service '$SERVICE_TO_START'" | ts
/usr/bin/python3 /kopano/$SERVICE_TO_START.py

echo "Set ownership" | ts
chown -R kopano:kopano /run /tmp
chown kopano:kopano /kopano/data/ /kopano/data/attachments

#echo "Clean old pid files and sockets" | ts
#rm -f /var/run/kopano/*

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]
then
    exec "$@"
    exit
fi

# start regular service
case "$SERVICE_TO_START" in
    server)
	# TODO the until loop needs to be extended for the other services and certificates
	until [[ -f $KCCONF_SERVER_SERVER_SSL_KEY_FILE && -f $KCCONF_SERVER_SERVER_SSL_CA_FILE ]]; do
		echo "waiting for $KCCONF_SERVER_SERVER_SSL_KEY_FILE & $KCCONF_SERVER_SERVER_SSL_CA_FILE"| ts
		sleep 5
	done
	dockerize -wait tcp://db:3306
        exec /usr/sbin/kopano-server -F
        ;;
    dagent)
        exec /usr/sbin/kopano-dagent -l
        ;;
    gateway)
        exec /usr/sbin/kopano-gateway -F
        ;;
    ical)
        exec /usr/sbin/kopano-ical -F
        ;;
    monitor)
        exec /usr/sbin/kopano-monitor -F
        ;;
    search)
        exec /usr/bin/python /usr/sbin/kopano-search -F
        ;;
    spooler)
        exec /usr/sbin/kopano-spooler -F
        ;;
    *)
        echo "Failed to start: Unknown service name: '$SERVICE_TO_START'" | ts
        exit 1
esac
