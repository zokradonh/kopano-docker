#!/bin/sh

set -eu
[ "$DEBUG" ] && set -x

DOCKERIZE_TIMEOUT=${DOCKERIZE_TIMEOUT:-360s}

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

signing_private_key=${signing_private_key:-"/etc/kopano/konnectd-signing-private-key.pem"}
validation_keys_path=${validation_keys_path:-"/etc/kopano/konnectkeys"}

if ! true >> "$signing_private_key"; then
	# file can not be created in this container, wait for external creation
	dockerize \
		-wait file://"$signing_private_key" \
		-timeout "$DOCKERIZE_TIMEOUT"
fi

if [ -f "${signing_private_key}" ] && [ ! -s "${signing_private_key}" ]; then
	mkdir -p "${validation_keys_path}"
	rnd=$(RANDFILE=/tmp/.rnd openssl rand -hex 2)
	key="${validation_keys_path}/konnect-$(date +%Y%m%d)-${rnd}.pem"
	>&2	echo "setup: creating new RSA private key at ${key} ..."
	RANDFILE=/tmp/.rnd openssl genpkey -algorithm RSA -out "${key}" -pkeyopt rsa_keygen_bits:4096 -pkeyopt rsa_keygen_pubexp:65537
	if [ -f "${key}" ]; then
		rm "$signing_private_key"
		ln -sn "${key}" "${signing_private_key}"
	fi
fi

encryption_secret_key=${encryption_secret_key:-"/etc/kopano/konnectd-encryption-secret.key"}
if ! true >> "$encryption_secret_key"; then
	# file can not be created in this container, wait for external creation
	dockerize \
		-wait file://"$encryption_secret_key" \
		-timeout "$DOCKERIZE_TIMEOUT"
fi

if [ -f "${encryption_secret_key}" ] && [ ! -s "${encryption_secret_key}" ]; then
	>&2	echo "setup: creating new secret key at ${encryption_secret_key} ..."
	RANDFILE=/tmp/.rnd openssl rand -out "${encryption_secret_key}" 32
fi

CONFIG_JSON=/tmp/konnectd-identifier-registration.yaml
yq -s '.[0] + .[1]' /etc/kopano/konnectd-identifier-registration.yaml "$identifier_registration_conf" | sponge "$CONFIG_JSON"

if [ "${allow_client_guests:-}" = "yes" ]; then
	# only modify identifier registration if it does not already contain the right settings
	if ! grep -q "konnect/guestok" "${identifier_registration_conf:?}"; then

		# TODO this could be simplified so that ecparam and eckey are only required if there is no jwk-meet.json yet
		ecparam=${ecparam:-/etc/kopano/ecparam.pem}
		if ! true >> "$ecparam"; then
			# ecparam can not be created in this container, wait for external creation
			dockerize \
				-wait file://"$ecparam" \
				-timeout "$DOCKERIZE_TIMEOUT"
		fi

		eckey=${eckey:-/etc/kopano/meet-kwmserver.pem}
		if ! true >> "$eckey"; then
			# eckey can not be created in this container, wait for external creation
			dockerize \
				-wait file://"$eckey" \
				-timeout "$DOCKERIZE_TIMEOUT"
		fi

		# Key generation for Meet guest mode
		if [ ! -s "$ecparam" ]; then
			echo "Creating ec param key for Meet guest mode ..."
			openssl ecparam -name prime256v1 -genkey -noout -out "$ecparam" >/dev/null 2>&1
		fi

		if [ ! -s "$eckey" ]; then
			echo "Creating ec private key for Meet guest mode..."
			openssl ec -in "$ecparam" -out "$eckey" >/dev/null 2>&1
		fi

		echo "Patching identifier registration for use of the Meet guest mode"
		/usr/local/bin/konnectd utils jwk-from-pem --use sig "$eckey" > /tmp/jwk-meet.json
		#yq -y ".clients += [{\"id\": \"grapi-explorer.js\", \"name\": \"Grapi Explorer\", \"application_type\": \"web\", \"trusted\": true, \"insecure\": true, \"redirect_uris\": [\"http://$FQDNCLEANED:3000/\"]}]" $CONFIG_JSON | sponge $CONFIG_JSON
		yq -y ".clients += [{\"id\": \"kpop-https://${FQDN%/*}/meet/\", \"name\": \"Kopano Meet\", \"application_type\": \"web\", \"trusted\": true, \"redirect_uris\": [\"https://${FQDN%/*}/meet/\"], \"trusted_scopes\": [\"konnect/guestok\", \"kopano/kwm\"], \"jwks\": {\"keys\": [{\"kty\": $(jq .kty /tmp/jwk-meet.json), \"use\": $(jq .use /tmp/jwk-meet.json), \"crv\": $(jq .crv /tmp/jwk-meet.json), \"d\": $(jq .d /tmp/jwk-meet.json), \"kid\": $(jq .kid /tmp/jwk-meet.json), \"x\": $(jq .x /tmp/jwk-meet.json), \"y\": $(jq .y /tmp/jwk-meet.json)}]},\"request_object_signing_alg\": \"ES256\"}]" $CONFIG_JSON | sponge $CONFIG_JSON
		# TODO this last bit can likely go (but then we must default to a registry stored below /etc/kopano)
		yq -y . $CONFIG_JSON | sponge "$identifier_registration_conf"
	else
		echo "Entrypoint: Skipping guest mode configuration, as it is already configured."
	fi
fi

if [ "${external_oidc_provider:-}" = "yes" ]; then
	echo "Patching identifier registration for external OIDC provider"
	echo "authorities: [{name: ${external_oidc_name:-}, default: yes, iss: ${external_oidc_url:-}, client_id: kopano-meet, client_secret: ${external_oidc_clientsecret:-}, authority_type: oidc, response_type: id_token, scopes: [openid, profile, email]}]" >> $CONFIG_JSON
	yq -y . $CONFIG_JSON | sponge "$identifier_registration_conf"
fi

# source additional configuration from Konnect cfg (potentially overwrites env vars)
if [ -e /etc/kopano/konnectd.cfg ]; then
	# shellcheck disable=SC1091
	. /etc/kopano/konnectd.cfg
fi

oidc_issuer_identifier=${oidc_issuer_identifier:-https://$FQDN}
echo "Entrypoint: Issuer url (--iss): $oidc_issuer_identifier"
set -- "$@" --iss="$oidc_issuer_identifier"

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

if [ -n "${signing_method:-}" ]; then
	echo "Entrypoint: Setting signing_method to $signing_method"
	set -- "$@" --signing-method="$signing_method"
fi

if [ "${insecure:-}" = "yes" ]; then
	echo "Entrypoint: running Konnect in insecure mode"
	set -- "$@" "--insecure"
fi

# Support additional args provided via environment.
if [ -n "${ARGS:-}" ]; then
	set -- "$@" "${ARGS}"
fi

# read password from file (UCS requirement)
if [ -n "${LDAP_BINDPW_FILE:-}" ]; then
	bindpw="$(cat "${LDAP_BINDPW_FILE}")"
	export LDAP_BINDPW="${bindpw}"
fi

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id \
	-timeout "$DOCKERIZE_TIMEOUT"
exec konnectd serve \
	--signing-private-key="$signing_private_key" \
	--encryption-secret="$encryption_secret_key" \
	--identifier-registration-conf "${identifier_registration_conf:?}" \
	--identifier-scopes-conf "${identifier_scopes_conf:?}" \
	"$@" "$KONNECT_BACKEND"
