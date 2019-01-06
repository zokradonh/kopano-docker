#!/bin/sh

mkdir -p /kopano/ssl/clients/

if [ ! -f /kopano/ssl/ca.pem ]; then
	# https://github.com/google/easypki
	echo "Creating CA and server certificates..."
	easypki create --filename internalca --organizational-unit primary --expire 3650 --ca "Internal Kopano System"

	for s in kserver kdagent kmonitor ksearch kspooler kwebapp; do
		easypki create --ca-name internalca --organizational-unit $s --expire 3650 $s
		cp /kopano/easypki/internalca/keys/$s.key /tmp/$s.pem
		cat /kopano/easypki/internalca/certs/$s.crt >> /tmp/$s.pem
		openssl x509 -in /kopano/easypki/internalca/certs/$s.crt -pubkey -noout > /tmp/$s-public.pem
		cp /tmp/$s.pem /kopano/ssl/$s.pem
		cp /tmp/$s-public.pem /kopano/ssl/clients/$s-public.pem
	done

	cp /kopano/easypki/internalca/certs/internalca.crt /kopano/ssl/ca.pem
fi

# Konnect - create encryption key if not already present
enckey="/kopano/ssl/konnectd-encryption.key"
if [ ! -f $enckey ]; then
	echo "creating new encryption key"
	openssl rand -out /tmp/konnectd-encryption.key 32
	cp /tmp/konnectd-encryption.key $enckey
fi

# Konnect - create token signing key if not already present
signkey="/kopano/ssl/konnectd-tokens-signing-key.pem"
if [ ! -f $signkey ]; then
	echo "creating new token signing key"
	openssl genpkey -algorithm RSA -out /tmp/konnectd-tokens-signing-key.pem -pkeyopt rsa_keygen_bits:4096
	cp /tmp/konnectd-tokens-signing-key.pem $signkey
fi

# Kapi
secretkey="/kopano/ssl/kapid-pubs-secret.key"
if [ ! -f $secretkey ]; then
	openssl rand -out /tmp/kapid-pubs-secret.key -hex 64
	cp /tmp/kapid-pubs-secret.key $secretkey
fi

ls -l /kopano/ssl/*.pem
ls -l /kopano/ssl/*.key
