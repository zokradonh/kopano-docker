#!/bin/sh

set -e

if [ -n "${log_level:-}" ]; then
	set -- "$@" --log-level="$log_level"
fi

# shellcheck disable=SC2154
if [ -n "${oidc_issuer_identifier:-}" ]; then
	set -- "$@" --iss="$oidc_issuer_identifier"
fi

if [ "${enable_guest_api:-}" = "yes" ]; then
	set -- "$@" --enable-guest-api
fi

if [ "$INSECURE" = "yes" ]; then
	set -- "$@" --insecure
fi

# kwmserver turn
# default to Kopano turn service
turn_service_url=${turn_service_url:-https://turnauth.kopano.com/turnserverauth/}

if [ -n "$turn_service_url" ]; then
	set -- "$@" --turn-service-url="$turn_service_url"
fi

if [ -n "${turn_service_credentials_user:-}" ] && [ -n "${turn_service_credentials_password:-}" ]; then
	turn_service_credentials=/tmp/turn_service_credentials
	echo "$turn_service_credentials_user":"$turn_service_credentials_password" > "$turn_service_credentials"
fi

if [ -n "${turn_service_credentials:-}" ]; then
	set -- "$@" --turn-service-credentials="$turn_service_credentials"
fi

if [ -n "${turn_server_shared_secret:-}" ]; then
	if [ ! -f "$turn_server_shared_secret" ]; then
		turn_server_shared_secret_file=/tmp/turn_server_shared_secret_file
		echo "$turn_server_shared_secret" > "$turn_server_shared_secret_file"
		turn_server_shared_secret="$turn_server_shared_secret_file"
	fi
	set -- "$@" --turn-server-shared-secret="$turn_server_shared_secret"
fi

if [ -n "${turn_uris:-}" ]; then
	for uri in $turn_uris; do
		set -- "$@" --turn-uri="$uri"
	done
fi

# kwmserver guest
if [ "${allow_guest_only_channels:-}" = "yes" ]; then
	set -- "$@" --allow-guest-only-channels
fi

if [ -n "${public_guest_access_regexp:-}" ]; then
	set -- "$@" --public-guest-access-regexp="$public_guest_access_regexp"
fi

if [ "$INSECURE" = "yes" ]; then
	dockerize \
	-skip-tls-verify \
	-wait "$oidc_issuer_identifier"/.well-known/openid-configuration \
	-timeout 360s
else
	dockerize \
	-wait "$oidc_issuer_identifier"/.well-known/openid-configuration \
	-timeout 360s
fi

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

registration_conf=${registration_conf:-/etc/kopano/kwmserverd-registration.yaml}

exec /usr/local/bin/docker-entrypoint.sh serve \
	--registration-conf "$registration_conf" \
	"$@"
