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

echo "Set config ownership" | ts
chown -R kopano:kopano /kopano/data /run /tmp

echo "Clean old pid files and sockets" | ts
rm -f /var/run/kopano/*

case "$SERVICE_TO_START" in
    server)
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