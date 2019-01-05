#!/bin/bash

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}

set -eu # unset variables are errors & non-zero return values exit the whole script

if [ ! -e /kopano/$SERVICE_TO_START.py ]; then
	echo "Invalid service specified: $SERVICE_TO_START" | ts
	exit 1
fi

[ ! -z "$ADDITIONAL_KOPANO_PACKAGES" ] && apt update
[ ! -z "$ADDITIONAL_KOPANO_PACKAGES" ] && for installpkg in "$ADDITIONAL_KOPANO_PACKAGES"; do
	if [ $(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		apt --assume-yes install $installpkg;
	fi
done

mkdir -p /kopano/data/attachments /tmp/$SERVICE_TO_START /var/run/kopano

echo "Configure core service '$SERVICE_TO_START'" | ts
/usr/bin/python3 /kopano/$SERVICE_TO_START.py

echo "Set ownership" | ts
chown -R kopano:kopano /run /tmp
chown kopano:kopano /kopano/data/ /kopano/data/attachments

# ensure removed pid-file on unclean shutdowns and mounted volumes
rm -f /var/run/kopano/$SERVICE_TO_START.pid

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

# start regular service
case "$SERVICE_TO_START" in
server)
	/kopano/services/kopano-public-store.sh &
	/kopano/services/kopano-users.sh &
	dockerize \
		-wait file://$KCCONF_SERVER_SERVER_SSL_CA_FILE \
		-wait file://$KCCONF_SERVER_SERVER_SSL_KEY_FILE \
		-wait tcp://db:3306 \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-server -F
	;;
dagent)
	dockerize \
		-wait file://var/run/kopano/server.sock \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-dagent -l
	;;
gateway)
	dockerize \
		-wait tcp://kopano_server:236 \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-gateway -F
	;;
ical)
	dockerize \
		-wait tcp://kopano_server:236 \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-ical -F
	;;
grapi)
	LC_CTYPE=en_US.UTF-8
	export socket_path=/var/run/kopano/grapi
	mkdir $socket_path
	chown -R kapi:kopano $socket_path
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-grapi serve
	;;
kapid)
	dockerize \
		-wait file://var/run/kopano/grapi/notify.sock \
		-timeout 360s
	LC_CTYPE=en_US.UTF-8
	sed -i s/\ *=\ */=/g /etc/kopano/kapid.cfg
	export $(grep -v '^#' /etc/kopano/kapid.cfg | xargs -d '\n')
	/usr/sbin/kopano-kapid setup
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-kapid serve --log-timestamp=false
	;;
monitor)
	dockerize \
		-wait file://var/run/kopano/server.sock \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-monitor -F
	;;
search)
	dockerize \
		-wait file://var/run/kopano/server.sock \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/bin/python3 /usr/sbin/kopano-search -F
	;;
spooler)
	dockerize \
		-wait file://var/run/kopano/server.sock \
		-wait tcp://mail:25 \
		-timeout 1080s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-spooler -F
	;;
*)
	echo "Failed to start: Unknown service name: '$SERVICE_TO_START'" | ts
	exit 1
esac
