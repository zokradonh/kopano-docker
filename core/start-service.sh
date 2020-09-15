#!/bin/bash

set -eu # unset variables are errors & non-zero return values exit the whole script
[ "$DEBUG" ] && set -x

ADDITIONAL_KOPANO_PACKAGES=${ADDITIONAL_KOPANO_PACKAGES:-""}
AUTOCONFIGURE=${AUTOCONFIGURE:-true} # when set to false will disable all automatic configuration actions
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
KCCONF_SPOOLER_SMTP_SERVER=${KCCONF_SPOOLER_SMTP_SERVER:-mail}
KCCONF_SPOOLER_SMTP_PORT=${KCCONF_SPOOLER_SMTP_PORT:-25}
KOPANO_CONFIG_PATH=${KOPANO_CONFIG_PATH:-/tmp/kopano}

if [ "${AUTOCONFIGURE}" == true ]; then
	# copy configuration files to /tmp/kopano (default value of $KOPANO_CONFIG_PATH)  to prevent modification of mounted config files
	mkdir -p /tmp/kopano
	cp /etc/kopano/*.cfg /tmp/kopano

	if [ ! -e /kopano/"$SERVICE_TO_START".py ]; then
		echo "Invalid service specified: $SERVICE_TO_START" | ts
		exit 1
	fi

	# Hint: this is not compatible with a read-only container.
	# The general recommendation is to already build a container that has all required packages installed.
	ADDITIONAL_KOPANO_PACKAGES=$(echo "$ADDITIONAL_KOPANO_PACKAGES" | tr -d '"')
	if mkdir -p "/var/lib/apt/lists/" 2&> /dev/null; then
		[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && apt update
		[ -n "${ADDITIONAL_KOPANO_PACKAGES// }" ] && for installpkg in $ADDITIONAL_KOPANO_PACKAGES; do
			# shellcheck disable=SC2016 disable=SC2086
			if [ "$(dpkg-query -W -f='${Status}' $installpkg 2>/dev/null | grep -c 'ok installed')" -eq 0 ]; then
				DEBIAN_FRONTEND=noninteractive apt --assume-yes --no-upgrade install "$installpkg"
			else
				echo "INFO: $installpkg is already installed"
			fi
		done
	else
		echo "Notice: Container is run read-only, skipping package installation."
		echo "If you want to have additional packages installed in the container either:"
		echo "- build your own image with the packages already included"
		echo "- switch the container to 'read_only: false'"
	fi

	mkdir -p /tmp/"$SERVICE_TO_START" /var/run/kopano

	# TODO is this still required now that we won't modify configuration mounted to /etc/kopano?
	if [ "${DISABLE_CONFIG_CHANGES}" == false ]; then
		echo "Configure core service '$SERVICE_TO_START'" | ts
		/kopano/"$SERVICE_TO_START".py
	fi

	# ensure removed pid-file on unclean shutdowns and mounted volumes
	rm -f /var/run/kopano/"$SERVICE_TO_START".pid
fi

coreversion=$(dpkg-query --showformat='${Version}' --show kopano-server)
echo "Using Kopano Groupware Core: $coreversion"

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

# services need to be aware of the machine-id
if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
	dockerize \
		-wait file:///etc/machine-id \
		-wait file:///var/lib/dbus/machine-id
fi

# put specified socket into KOPANO_CON variable to ease checks further down
case "$SERVICE_TO_START" in
dagent)
	EXE="${EXE:-$(command -v kopano-dagent)}"
	KOPANO_CON="$KCCONF_DAGENT_SERVER_SOCKET"
	;;
gateway)
	EXE="${EXE:-$(command -v kopano-gateway)}"
	KOPANO_CON="$KCCONF_GATEWAY_SERVER_SOCKET"
	;;
grapi)
	EXE="${EXE:-$(command -v kopano-grapi)}"
	;;
ical)
	EXE="${EXE:-$(command -v kopano-ical)}"
	KOPANO_CON="$KCCONF_ICAL_SERVER_SOCKET"
	;;
kapi)
	EXE="${EXE:-$(command -v kopano-kapid)}"
	;;
monitor)
	EXE="${EXE:-$(command -v kopano-monitor)}"
	KOPANO_CON="$KCCONF_MONITOR_SERVER_SOCKET"
	;;
search)
	EXE="${EXE:-$(command -v kopano-search)}"
	KOPANO_CON="$KCCONF_SEARCH_SERVER_SOCKET"
	;;
server)
	EXE="${EXE:-$(command -v kopano-server)}"
	;;
spamd)
	EXE="${EXE:-$(command -v kopano-spamd)}"
	;;
spooler)
	EXE="${EXE:-$(command -v kopano-spooler)}"
	KOPANO_CON="$KCCONF_SPOOLER_SERVER_SOCKET"
	;;
esac
if [[ "$KOPANO_CON"  =~ ^http.* ]]; then
	KOPANO_CON=$(sed 's/.*\/\//tcp:\/\//' <<< "$KOPANO_CON")
fi

# start regular service
case "$SERVICE_TO_START" in
server)
	if [ "${AUTOCONFIGURE}" == true ]; then
		echo "Set ownership" | ts
		mkdir -p /kopano/data/attachments
		chown kopano:kopano /kopano/data/ /kopano/data/attachments

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
			kopano-dbadm -c "$KOPANO_CONFIG_PATH/server.cfg" populate
		fi
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -F
	;;
dagent)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -l
	;;
gateway)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -F
	;;
ical)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -F
	;;
grapi)
	if [ "${AUTOCONFIGURE}" == true ]; then
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
		sed s/\ *=\ */=/g "$KOPANO_CONFIG_PATH/grapi.cfg" > /tmp/grapi-env
		# shellcheck disable=SC2046
		export $(grep -v '^#' /tmp/grapi-env | xargs -d '\n')
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	# the backend option is only available in more recent versions of grapi
	grapiversion=$(dpkg-query --showformat='${Version}' --show kopano-grapi)
	echo "Using Kopano Grapi: $grapiversion"
	if dpkg --compare-versions "$grapiversion" "gt" "10.0.0"; then
		exec "$EXE" serve --backend="$GRAPI_BACKEND"
	else
		exec "$EXE" serve
	fi
	;;
kapi)
	if [ "${AUTOCONFIGURE}" == true ]; then
		mkdir -p /kopano/data/kapi-kvs
		if [ "$KCCONF_KAPID_INSECURE" = "yes" ]; then
			dockerize \
			-skip-tls-verify \
			-wait "$KCCONF_KAPID_OIDC_ISSUER_IDENTIFIER"/.well-known/openid-configuration \
			-timeout 360s
		else
			dockerize \
			-wait "$KCCONF_KAPID_OIDC_ISSUER_IDENTIFIER"/.well-known/openid-configuration \
			-timeout 360s
		fi
		LC_CTYPE=en_US.UTF-8
		sed s/\ *=\ */=/g "$KOPANO_CONFIG_PATH/kapid.cfg" > /tmp/kapid-env
		# shellcheck disable=SC2046
		export $(grep -v '^#' /tmp/kapid-env | xargs -d '\n')
		"$EXE" setup
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	kapiversion=$(dpkg-query --showformat='${Version}' --show kopano-kapid)
	echo "Using Kopano Kapi: $kapiversion"
	exec "$EXE" serve --log-timestamp=false
	;;
monitor)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -F
	;;
search)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
		# give kopano-server a moment to settler before starting search
		sleep 5
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	# with commit 702bb3fccb3 search does not need -F any longer
	searchversion=$(dpkg-query --showformat='${Version}' --show kopano-search)
	if dpkg --compare-versions "$searchversion" "gt" "8.7.82.165"; then
		exec "$EXE" --config "$KOPANO_CONFIG_PATH/search.cfg"
	else
		exec /usr/bin/python3 "$EXE" --config "$KOPANO_CONFIG_PATH/search.cfg" -F
	fi
	;;
spamd)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-timeout 360s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" --config "$KOPANO_CONFIG_PATH/spamd.cfg" -F
	;;
spooler)
	if [ "${AUTOCONFIGURE}" == true ] && [ "$DISABLE_CHECKS" == false ]; then
		dockerize \
			-wait "$KOPANO_CON" \
			-wait tcp://"$KCCONF_SPOOLER_SMTP_SERVER":"$KCCONF_SPOOLER_SMTP_PORT" \
			-timeout 1080s
	fi
	# cleaning up env variables
	unset "${!KCCONF_@}"
	exec "$EXE" -F
	;;
*)
	echo "Failed to start: Unknown service name: '$SERVICE_TO_START'" | ts
	exit 1
esac
