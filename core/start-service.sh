#!/bin/bash

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
KCCONF_SERVER_MYSQL_SOCKET=${KCCONF_SERVER_MYSQL_SOCKET:-""}
DISABLE_CHECKS=${DISABLE_CHECKS:-false}
DISABLE_CONFIG_CHANGES=${DISABLE_CONFIG_CHANGES:-false}
KCCONF_DAGENT_SERVER_SOCKET=${KCCONF_DAGENT_SERVER_SOCKET:-"file:///var/run/kopano/server.sock"}
KCCONF_GATEWAY_SERVER_SOCKET=${KCCONF_GATEWAY_SERVER_SOCKET:-"tcp://kopano_server:236"}
KCCONF_ICAL_SERVER_SOCKET=${KCCONF_ICAL_SERVER_SOCKET:-"tcp://kopano_server:236"}
KCCONF_MONITOR_SERVER_SOCKET=${KCCONF_MONITOR_SERVER_SOCKET:-"file:///var/run/kopano/server.sock"}
KCCONF_SEARCH_SERVER_SOCKET=${KCCONF_SEARCH_SERVER_SOCKET:-"file:///var/run/kopano/server.sock"}
KCCONF_SPOOLER_SERVER_SOCKET=${KCCONF_SPOOLER_SERVER_SOCKET:-"file:///var/run/kopano/server.sock"}
KOPANO_CON=${KOPANO_CON:-"file:///var/run/kopano/server.sock"}

# copy configuration files to /tmp/kopano to prevent modification of mounted config files
mkdir -p /tmp/kopano
cp /etc/kopano/*.cfg /tmp/kopano

if [ ! -e /kopano/"$SERVICE_TO_START".py ]; then
	echo "Invalid service specified: $SERVICE_TO_START" | ts
	exit 1
fi

# Hint: this is not compatible with a read-only container.
# The general recommendation is to already build a container that has all required packages installed.
ADDITIONAL_KOPANO_PACKAGES=$(echo "$ADDITIONAL_KOPANO_PACKAGES" | tr -d '"')
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
	# shellcheck disable=SC2016 disable=SC2086
	if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
		DEBIAN_FRONTEND=noninteractive apt --assume-yes --no-upgrade install "$installpkg"
	else
		echo "INFO: $installpkg is already installed"
	fi
done

mkdir -p /tmp/"$SERVICE_TO_START" /var/run/kopano

# TODO is this still required now that we won't modify configuration mounted to /etc/kopano?
if [ "${DISABLE_CONFIG_CHANGES}" == false ]; then
	echo "Configure core service '$SERVICE_TO_START'" | ts
	/usr/bin/python3 /kopano/"$SERVICE_TO_START".py
fi

# ensure removed pid-file on unclean shutdowns and mounted volumes
rm -f /var/run/kopano/"$SERVICE_TO_START".pid

coreversion=$(dpkg-query --showformat='${Version}' --show kopano-server)
echo "Using Kopano Groupware Core: $coreversion"

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

# services need to be aware of the machine-id
if [[ "$DISABLE_CHECKS" == false  ]]; then
	dockerize \
		-wait file:///etc/machine-id \
		-wait file:///var/lib/dbus/machine-id
fi

# put specified socket into KOPANO_CON variable to ease checks further down
case "$SERVICE_TO_START" in
dagent)
	KOPANO_CON="$KCCONF_DAGENT_SERVER_SOCKET"
	;;
gateway)
	KOPANO_CON="$KCCONF_GATEWAY_SERVER_SOCKET"
	;;
ical)
	KOPANO_CON="$KCCONF_ICAL_SERVER_SOCKET"
	;;
monitor)
	KOPANO_CON="$KCCONF_MONITOR_SERVER_SOCKET"
	;;
search)
	KOPANO_CON="$KCCONF_SEARCH_SERVER_SOCKET"
	;;
spooler)
	KOPANO_CON="$KCCONF_SPOOLER_SERVER_SOCKET"
	;;
esac
if [[ "$KOPANO_CON"  =~ ^http.* ]]; then
	KOPANO_CON=$(sed 's/.*\/\//tcp:\/\//' <<< "$KOPANO_CON")
fi

# start regular service
case "$SERVICE_TO_START" in
server)
	echo "Set ownership" | ts
	mkdir -p /kopano/data/attachments
	chown kopano:kopano /kopano/data/ /kopano/data/attachments
	# Hint: if additional locales are required that should be added in base/Dockerfile
	export KCCONF_ADMIN_DEFAULT_STORE_LOCALE=${KCCONF_ADMIN_DEFAULT_STORE_LOCALE:-"en_US.UTF-8"}

	if [[ "$DISABLE_CHECKS" == false ]]; then
		# determine db connection mode (unix vs. network socket)
		if [ -n "$KCCONF_SERVER_MYSQL_SOCKET" ]; then
			DB_CON="file://$KCCONF_SERVER_MYSQL_SOCKET"
		else
			DB_CON="tcp://$KCCONF_SERVER_MYSQL_HOST:$KCCONF_SERVER_MYSQL_PORT"
		fi

		dockerize \
			-wait file://"$KCCONF_SERVER_SERVER_SSL_CA_FILE" \
			-wait file://"$KCCONF_SERVER_SERVER_SSL_KEY_FILE" \
			-wait "$DB_CON" \
			-timeout 360s
	fi
	# pre populate database
	if dpkg --compare-versions "$coreversion" "gt" "8.7.84"; then
		kopano-dbadm -c /tmp/kopano/server.cfg populate
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-server --config /tmp/kopano/server.cfg -F
	;;
dagent)
	dockerize \
		-wait "$KOPANO_CON" \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-dagent --config /tmp/kopano/dagent.cfg -l
	;;
gateway)
	dockerize \
		-wait "$KOPANO_CON" \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-gateway --config /tmp/kopano/gateway.cfg -F
	;;
ical)
	dockerize \
		-wait "$KOPANO_CON" \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-ical --config /tmp/kopano/ical.cfg -F
	;;
grapi)
	LC_CTYPE=en_US.UTF-8
	export socket_path=/var/run/kopano/grapi
	export pid_file="$socket_path/grapi.pid"
	mkdir -p "$socket_path" /var/lib/kopano-grapi
	chown -R kapi:kopano "$socket_path"
	chown kapi:kopano /var/lib/kopano-grapi
	# TODO there could be a case where multiple backends are desired
	case $GRAPI_BACKEND in
	ldap)
		[ -n "$KCCONF_GRAPI_LDAP_URI" ] && export LDAP_URI="${KCCONF_GRAPI_LDAP_URI}"
		[ -n "$KCCONF_GRAPI_LDAP_BASEDN" ] && export LDAP_BASEDN="${KCCONF_GRAPI_LDAP_BASEDN}"
		[ -n "$KCCONF_GRAPI_LDAP_BINDDN" ] && export LDAP_BINDDN="${KCCONF_GRAPI_LDAP_BINDDN}"
		if [ -n "$KCCONF_GRAPI_LDAP_BINDPW_FILE" ]; then
			bindpw="$(cat "${KCCONF_GRAPI_LDAP_BINDPW_FILE}")"
			export LDAP_BINDPW="${bindpw}"
		fi
		;;
	esac
	sed s/\ *=\ */=/g /tmp/kopano/grapi.cfg > /tmp/grapi-env
	# shellcheck disable=SC2046
	export $(grep -v '^#' /tmp/grapi-env | xargs -d '\n')
	# cleaning up env variables
	unset "${!KCCONF_@}"
	# the backend option is only available in more recent versions of grapi
	grapiversion=$(dpkg-query --showformat='${Version}' --show kopano-grapi)
	echo "Using Kopano Grapi: $grapiversion"
	if dpkg --compare-versions "$grapiversion" "gt" "10.0.0"; then
		exec kopano-grapi serve --backend="$GRAPI_BACKEND"
	else
		exec kopano-grapi serve
	fi
	;;
kapi)
	mkdir -p /kopano/data/kapi-kvs
	if [ "$KCCONF_KAPID_INSECURE" = "yes" ]; then
		dockerize \
		-skip-tls-verify \
		-wait file:///var/run/kopano/grapi/notify.sock \
		-wait "$KCCONF_KAPID_OIDC_ISSUER_IDENTIFIER"/.well-known/openid-configuration \
		-timeout 360s
	else
		dockerize \
		-wait file:///var/run/kopano/grapi/notify.sock \
		-wait "$KCCONF_KAPID_OIDC_ISSUER_IDENTIFIER"/.well-known/openid-configuration \
		-timeout 360s
	fi
	kapiversion=$(dpkg-query --showformat='${Version}' --show kopano-kapid)
	echo "Using Kopano Kapi: $kapiversion"
	LC_CTYPE=en_US.UTF-8
	sed s/\ *=\ */=/g /tmp/kopano/kapid.cfg > /tmp/kapid-env
	# shellcheck disable=SC2046
	export $(grep -v '^#' /tmp/kapid-env | xargs -d '\n')
	kopano-kapid setup
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec kopano-kapid serve --log-timestamp=false
	;;
monitor)
	dockerize \
		-wait "$KOPANO_CON" \
		-timeout 360s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-monitor --config /tmp/kopano/monitor.cfg -F
	;;
search)
	dockerize \
		-wait "$KOPANO_CON" \
		-timeout 360s
	# give kopano-server a moment to settler before starting search
	sleep 5
	# cleaning up env variables
	unset "${!KCCONF_@}"
	# with commit 702bb3fccb3 search does not need -F any longer
	searchversion=$(dpkg-query --showformat='${Version}' --show kopano-search)
	if dpkg --compare-versions "$searchversion" "gt" "8.7.82.165"; then
		exec /usr/sbin/kopano-search --config /tmp/kopano/search.cfg
	else
		exec /usr/bin/python3 /usr/sbin/kopano-search --config /tmp/kopano/search.cfg -F
	fi
	;;
spooler)
	dockerize \
		-wait "$KOPANO_CON" \
		-wait tcp://"$KCCONF_SPOOLER_SMTP_SERVER":25 \
		-timeout 1080s
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec /usr/sbin/kopano-spooler --config /tmp/kopano/spooler.cfg -F
	;;
*)
	echo "Failed to start: Unknown service name: '$SERVICE_TO_START'" | ts
	exit 1
esac
