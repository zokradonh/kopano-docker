#!/bin/bash

set -eo pipefail

cronfile=/tmp/crontab

# purge existing entries from crontab
true > "$cronfile"

for cronvar in ${!CRON_*}; do
	cronvalue=${!cronvar}
	echo "Adding $cronvalue to crontab"
	echo "$cronvalue" >> "$cronfile"
done

for cronvar in ${!CRONDELAYED_*}; do
	cronvalue=${!cronvar}
	echo "Adding $cronvalue to crontab (delayed)"
	echo "$cronvalue" >> "$cronfile"
done

# wait for kopano_server statup to run one-off commands
dockerize \
	-wait tcp://kopano_server:236 \
	-timeout 360s

echo "Creating public store"
docker exec kopano_server kopano-storeadm -h file://kopano/sockets/server.sock -P || true

echo "Running sheduled cron jobs once"
for cronvar in ${!CRON_*}; do
	cronvalue=${!cronvar}
	croncommand=$(echo "$cronvalue" | cut -d ' ' -f 6-)
	echo "Running: $croncommand"
	$croncommand
done

supercronic -test $cronfile
exec supercronic $cronfile
