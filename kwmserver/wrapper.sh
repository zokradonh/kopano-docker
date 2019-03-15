#!/bin/sh

set -e

# shellcheck disable=SC2154
if [ -n "$oidc_issuer_identifier" ]; then
	set -- "$@" --iss="$oidc_issuer_identifier"
fi

if [ "$enable_guest_api" = "yes" ]; then
	set -- "$@" --enable-guest-api
fi

if [ "$INSECURE" = "yes" ]; then
	set -- "$@" --insecure
fi

# kwmserver turn
if [ -z "$turn_service_url" ]; then
	turn_service_url=https://turnauth.kopano.com/turnserverauth/
fi

if [ -n "$turn_service_url" ]; then
	set -- "$@" --turn-service-url="$turn_service_url"
fi

if [ -n "$turn_service_credentials" ]; then
	set -- "$@" --turn-service-credentials="$$turn_service_credentials"
	fi

if [ -n "$turn_server_shared_secret" ]; then
	set -- "$@" --turn-server-shared-secret="$turn_server_shared_secret"
fi

if [ -n "$turn_uris" ]; then
	for uri in $turn_uris; do
		set -- "$@" --turn-uri="$uri"
	done
fi

# kwmserver guest
if [ "$allow_guest_only_channels" = "yes" ]; then
	set -- "$@" --allow-guest-only-channels
fi

if [ -n "$public_guest_access_regexp" ]; then
	set -- "$@" --public-guest-access-regexp="$public_guest_access_regexp"
fi

registration_conf=/kopano/ssl/konnectd-identifier-registration.yaml

exec dockerize \
        -wait file://$registration_conf \
        -timeout 360s \
	/usr/local/bin/docker-entrypoint.sh serve "$@"
