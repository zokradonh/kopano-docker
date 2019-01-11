#!/bin/sh

set -e

if [ "$INSECURE" = "yes" ]; then
	exec kwmserverd serve \
		--insecure \
		--iss="https://$oidc_issuer_identifier"
else
	exec kwmserverd serve \
		--iss="https://$oidc_issuer_identifier"
fi

