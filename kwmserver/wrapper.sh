#!/bin/sh

set -e

# shellcheck disable=SC2154
if [ -n "$oidc_issuer_identifier" ]; then
	set -- "$@" --iss="$oidc_issuer_identifier"
fi

if [ "$INSECURE" = "yes" ]; then
	set -- "$@" --insecure
fi

exec /usr/local/bin/docker-entrypoint.sh serve "$@"

