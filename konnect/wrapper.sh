#!/bin/sh

set -eu
[ "$DEBUG" ] && set -x

dockerize \
	-wait file://"${ecparam:?}" \
	-wait file://"${eckey:?}" \
	-timeout 360s

# Key generation for Meet guest mode
if [ ! -s "$ecparam" ]; then
	echo "Creating ec param key for Meet..."
	openssl ecparam -name prime256v1 -genkey -noout -out "$ecparam" >/dev/null 2>&1
fi

if [ ! -s "$eckey" ]; then
	echo "Creating ec key for Meet..."
	openssl ec -in "$ecparam" -out "$eckey" >/dev/null 2>&1
fi

if [ "${allow_client_guests:-}" = "yes" ]; then
	echo "Patching identifier registration for use of the Meet guest mode"
	konnectd utils jwk-from-pem --use sig "$eckey" > /tmp/jwk-meet.json
	CONFIG_JSON=/etc/kopano/konnectd-identifier-registration.yaml
	#yq -y ".clients += [{\"id\": \"grapi-explorer.js\", \"name\": \"Grapi Explorer\", \"application_type\": \"web\", \"trusted\": true, \"insecure\": true, \"redirect_uris\": [\"http://$FQDNCLEANED:3000/\"]}]" $CONFIG_JSON | sponge $CONFIG_JSON
	yq -y ".clients += [{\"id\": \"kpop-https://$FQDN/meet/\", \"name\": \"Kopano Meet\", \"application_type\": \"web\", \"trusted\": true, \"redirect_uris\": [\"https://$FQDN/meet/\"], \"trusted_scopes\": [\"konnect/guestok\", \"kopano/kwm\"], \"jwks\": {\"keys\": [{\"kty\": $(jq .kty /tmp/jwk-meet.json), \"use\": $(jq .use /tmp/jwk-meet.json), \"crv\": $(jq .crv /tmp/jwk-meet.json), \"d\": $(jq .d /tmp/jwk-meet.json), \"kid\": $(jq .kid /tmp/jwk-meet.json), \"x\": $(jq .x /tmp/jwk-meet.json), \"y\": $(jq .y /tmp/jwk-meet.json)}]},\"request_object_signing_alg\": \"ES256\"}]" $CONFIG_JSON | sponge $CONFIG_JSON
	# TODO this last bit can likely go
	yq -y . $CONFIG_JSON | sponge /kopano/ssl/konnectd-identifier-registration.yaml
fi

if [ "${external_oidc_provider:-}" = "yes" ]; then
	# TODO needs FQDN of OIDC and client secret
	yq -y ".authorities += [{name: ucs-konnect, default: yes, iss: 'https://ucs-sso.kopano.intranet', client_id: konnect, client_secret: konnect, authority_type: oidc, discover: true, response_type: id_token, insecure: true, identity_claim_name: sub, scopes: [openid, profile, email]}]}" $CONFIG_JSON | sponge $CONFIG_JSON
fi

# source additional configuration from Konnect cfg (potentially overwrites env vars)
if [ -e /etc/kopano/konnectd.cfg ]; then
	# shellcheck disable=SC1091
	. /etc/kopano/konnectd.cfg
fi

oidc_issuer_identifier=${oidc_issuer_identifier:-https://$FQDN}
set -- "$@" --iss="$oidc_issuer_identifier"
echo "Entrypoint: Issuer url (--iss): $oidc_issuer_identifier"

if [ -n "${log_level:-}" ]; then
	echo "Entrypoint: Setting logging to $log_level"
	set -- "$@" --log-level="$log_level"
fi

if [ "${allow_client_guests:-}" = "yes" ]; then
	echo "Entrypoint: Allowing guest login"
	set -- "$@" "--allow-client-guests"
fi

if [ "${allow_dynamic_client_registration:-}" = "yes" ]; then
	echo "Entrypoint: Allowing dynamic client registration"
	set -- "$@" "--allow-dynamic-client-registration"
fi

if [ -n "${uri_base_path:-}" ]; then
	echo "Entrypoint: Setting base-path to $uri_base_path"
	set -- "$@" --uri-base-path="$uri_base_path"
fi

if [ "${insecure:-}" = "yes" ]; then
	echo "Entrypoint: running Konnect in insecure mode"
	set -- "$@" "--insecure"
fi

# read password from file (UCS requirement)
if [ -n "${LDAP_BINDPW_FILE:-}" ]; then
	bindpw="$(cat "${LDAP_BINDPW_FILE}")"
	export LDAP_BINDPW="${bindpw}"
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
