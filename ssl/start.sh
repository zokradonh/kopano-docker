#!/bin/sh

if [ ! -f /kopano/ssl/ca.pem ]; then
	# https://github.com/google/easypki
	echo "Creating CA and Server certificates..."
	easypki create --filename internalca --organizational-unit primary --expire 3650 --ca "Internal Kopano System"

	mkdir -p /kopano/ssl/clients/
	cp /kopano/easypki/internalca/certs/internalca.crt /kopano/ssl/ca.pem

	for s in kserver kdagent kmonitor ksearch kspooler kwebapp; do
		easypki create --ca-name internalca --organizational-unit $s --expire 3650 $s
		cp /kopano/easypki/internalca/keys/$s.key /kopano/ssl/$s.pem
		cat /kopano/easypki/internalca/certs/$s.crt >> /kopano/ssl/$s.pem
		openssl x509 -in /kopano/easypki/internalca/certs/$s.crt -pubkey -noout > /kopano/ssl/clients/$s-public.pem
	done
fi

# Konnect - create encryption key if not already present
encckey="/kopano/ssl/konnectd-encryption.key"
if [ ! -f $encckey ]; then
	echo "creating new encryption key"
	openssl rand -out /etc/kopano/konnectd-encryption.key 32
fi

# Konnec - create token signing key if not already present
singkey="/kopano/ssl/konnectd-tokens-signing-key.pem"
if [ ! -f $signkey ]; then
	echo "creating new token signing key"
	openssl genpkey -algorithm RSA -out $signkey -pkeyopt rsa_keygen_bits:4096
fi

ls -l /kopano/ssl/*.pem
ls -l /kopano/ssl/*.key
