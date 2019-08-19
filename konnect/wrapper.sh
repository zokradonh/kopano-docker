#!/bin/sh

set -e

dockerize \
	-wait file:///kopano/ssl/meet-kwmserver.pem \
	-timeout 360s
cd /kopano/ssl/

konnectd utils jwk-from-pem --use sig /kopano/ssl/meet-kwmserver.pem > /tmp/jwk-meet.json
CONFIG_JSON=/etc/kopano/konnectd-identifier-registration.yaml
yq -y ".clients |= [{\"id\": \"kpop-https://$FQDN/meet/\", \"name\": \"Kopano Meet\", \"application_type\": \"web\", \"trusted\": true, \"redirect_uris\": [\"https://$FQDN/meet/\"], \"trusted_scopes\": [\"konnect/guestok\", \"kopano/kwm\"], \"jwks\": {\"keys\": [{\"kty\": $(jq .kty /tmp/jwk-meet.json), \"use\": $(jq .use /tmp/jwk-meet.json), \"crv\": $(jq .crv /tmp/jwk-meet.json), \"d\": $(jq .d /tmp/jwk-meet.json), \"kid\": $(jq .kid /tmp/jwk-meet.json), \"x\": $(jq .x /tmp/jwk-meet.json), \"y\": $(jq .y /tmp/jwk-meet.json)}]},\"request_object_signing_alg\": \"ES256\"}]" $CONFIG_JSON | sponge /kopano/ssl/konnectd-identifier-registration.yaml

# shellcheck disable=SC2154
if [ -n "$log_level" ]; then
	set -- "$@" --log-level="$log_level"
fi

# shellcheck disable=SC2154
if [ "$allow_client_guests" = "yes" ]; then
	set -- "$@" "--allow-client-guests"
fi

# shellcheck disable=SC2154
if [ "$allow_dynamic_client_registration" = "yes" ]; then
	set -- "$@" "--allow-dynamic-client-registration"
fi

dockerize \
	-wait file:///kopano/ssl/konnectd-tokens-signing-key.pem \
	-wait file:///kopano/ssl/konnectd-encryption.key \
	-timeout 360s
konnectd serve \
	--signing-private-key=/kopano/ssl/konnectd-tokens-signing-key.pem \
	--encryption-secret=/kopano/ssl/konnectd-encryption.key \
	--iss=https://"$FQDN" \
	--identifier-registration-conf /kopano/ssl/konnectd-identifier-registration.yaml \
	--identifier-scopes-conf /etc/kopano/konnectd-identifier-scopes.yaml \
	"$@" kc
