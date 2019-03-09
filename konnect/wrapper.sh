#!/bin/sh

set -e

dockerize \
	-wait file:///kopano/ssl/meet-kwmserver.pem \
	-timeout 360s
cd /kopano/ssl/ && konnectd utils --use sig jwk-from-pem meet-kwmserver.pem > meet-jwk.json

dockerize \
	-wait file:///kopano/ssl/konnectd-tokens-signing-key.pem \
	-wait file:///kopano/ssl/konnectd-encryption.key \
	-timeout 360s \
	konnectd serve \
	--signing-private-key=/kopano/ssl/konnectd-tokens-signing-key.pem \
	--encryption-secret=/kopano/ssl/konnectd-encryption.key \
	--iss=https://"$FQDN" \
	--identifier-registration-conf /etc/kopano/konnectd-identifier-registration.yaml \
	--identifier-scopes-conf /etc/kopano/konnectd-identifier-scopes.yaml \
	kc
