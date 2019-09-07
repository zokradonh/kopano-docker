#!/bin/sh

set -eu
[ "$DEBUG" ] && set -x

# Key generation for Meet guest mode
ecparam="/tmp/ecparam.pem"
echo "Creating ec param key for Meet..."
openssl ecparam -name prime256v1 -genkey -noout -out $ecparam.tmp >/dev/null 2>&1
mv $ecparam.tmp $ecparam

eckey="/tmp/meet-kwmserver.pem"
echo "Creating ec key for Meet..."
openssl ec -in $ecparam -out $eckey.tmp >/dev/null 2>&1
mv $eckey.tmp $eckey

konnectd utils jwk-from-pem --use sig /tmp/meet-kwmserver.pem > /tmp/jwk-meet.json
CONFIG_JSON=/etc/kopano/konnectd-identifier-registration.yaml
#yq -y ".clients += [{\"id\": \"grapi-explorer.js\", \"name\": \"Grapi Explorer\", \"application_type\": \"web\", \"trusted\": true, \"insecure\": true, \"redirect_uris\": [\"http://$FQDNCLEANED:3000/\"]}]" $CONFIG_JSON | sponge $CONFIG_JSON
yq -y ".clients += [{\"id\": \"kpop-https://$FQDN/meet/\", \"name\": \"Kopano Meet\", \"application_type\": \"web\", \"trusted\": true, \"redirect_uris\": [\"https://$FQDN/meet/\"], \"trusted_scopes\": [\"konnect/guestok\", \"kopano/kwm\"], \"jwks\": {\"keys\": [{\"kty\": $(jq .kty /tmp/jwk-meet.json), \"use\": $(jq .use /tmp/jwk-meet.json), \"crv\": $(jq .crv /tmp/jwk-meet.json), \"d\": $(jq .d /tmp/jwk-meet.json), \"kid\": $(jq .kid /tmp/jwk-meet.json), \"x\": $(jq .x /tmp/jwk-meet.json), \"y\": $(jq .y /tmp/jwk-meet.json)}]},\"request_object_signing_alg\": \"ES256\"}]" $CONFIG_JSON | sponge $CONFIG_JSON
yq -y . $CONFIG_JSON | sponge /kopano/ssl/konnectd-identifier-registration.yaml

# source additional configuration from Konnect cfg (potentially overwrites env vars)
if [ -e /etc/kopano/konnectd.cfg ]; then
	# shellcheck disable=SC1091
	. /etc/kopano/konnectd.cfg
fi

oidc_issuer_identifier=${oidc_issuer_identifier:-https://$FQDN}
set -- "$@" --iss="$oidc_issuer_identifier"
echo "Entrypoint: Issuer url (--iss): $oidc_issuer_identifier"

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
	echo "Entrypoint: Allowing dynamic client registration"
	set -- "$@" "--allow-dynamic-client-registration"
fi

dockerize \
	-wait file://"${signing_private_key:?}" \
	-wait file://"${encryption_secret_key:?}" \
	-timeout 360s
exec konnectd serve \
	--signing-private-key="${signing_private_key:?}" \
	--encryption-secret="${encryption_secret_key:?}" \
	--identifier-registration-conf "${identifier_registration_conf:?}" \
	--identifier-scopes-conf "${identifier_scopes_conf:?}" \
	"$@" "$KONNECT_BACKEND"
