#!/bin/bash

set -eo pipefail

cronfile=/etc/crontab

for cronvar in ${!CRON_*}; do
	cronvalue=${!cronvar}
	echo "Adding $cronvalue to crontab"
	echo "$cronvalue" >> "$cronfile"
done

# wait for kopano_server statup to run one-off commands
dockerize \
	-wait tcp://kopano_server:236 \
	-timeout 360s
echo "creating public store"
docker exec kopano_server kopano-storeadm -h default: -P || true

# run sheduled cron jobs once
for cronvar in ${!CRON_*}; do
	cronvalue=${!cronvar}
	croncommand=$(echo "$cronvalue" | cut -d ' ' -f 6-)
	echo "Runnin: $croncommand"
	$croncommand
done

exec supercronic /etc/crontab
