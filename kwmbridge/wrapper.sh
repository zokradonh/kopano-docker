#!/bin/sh

set -e
[ "$DEBUG" ] && set -x

if [ -n "${log_level:-}" ]; then
	set -- "$@" --log-level="$log_level"
fi

# shellcheck disable=SC2154
if [ -n "${oidc_issuer_identifier:-}" ]; then
	set -- "$@" --iss="$oidc_issuer_identifier"
fi

if [ "$INSECURE" = "yes" ]; then
	set -- "$@" --insecure
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

exec /usr/local/bin/docker-entrypoint.sh serve \
	"$@"
