#!/bin/sh

set -e

if [ -n "$oidc_issuer_identifier" ]; then
	set -- "$@" --iss="$oidc_issuer_identifier"
fi

if [ "$INSECURE" = "yes" ]; then
	set -- "$@" --insecure
fi

exec kwmserverd serve "$@"

