#!/bin/sh

mkdir -p /kopano/ssl/clients/

if [ ! -f /kopano/ssl/ca.pem ]; then
	# https://github.com/google/easypki
	echo "Creating CA and server certificates..."
	easypki create --filename internalca --organizational-unit primary --expire 3650 --ca "Internal Kopano System"

	for s in kserver kdagent kmonitor ksearch kspooler kwebapp; do
		easypki create --ca-name internalca --organizational-unit $s --expire 3650 $s
		cp /kopano/easypki/internalca/keys/$s.key /kopano/ssl/$s.pem.tmp
		cat /kopano/easypki/internalca/certs/$s.crt >> /kopano/ssl/$s.pem.tmp
		openssl x509 -in /kopano/easypki/internalca/certs/$s.crt -pubkey -noout >  /kopano/ssl/clients/$s-public.pem.tmp
		mv /kopano/ssl/$s.pem.tmp /kopano/ssl/$s.pem
		mv /kopano/ssl/clients/$s-public.pem.tmp /kopano/ssl/clients/$s-public.pem
	done

	cp /kopano/easypki/internalca/certs/internalca.crt /kopano/ssl/ca.pem.tmp
	mv /kopano/ssl/ca.pem.tmp /kopano/ssl/ca.pem
fi

# Konnect - create encryption key if not already present
enckey="/kopano/ssl/konnectd-encryption.key"
if [ ! -f $enckey ]; then
	echo "creating new encryption key"
	openssl rand -out $enckey.tmp 32
	mv $enckey.tmp $enckey
fi

# Konnect - create token signing key if not already present
signkey="/kopano/ssl/konnectd-tokens-signing-key.pem"
if [ ! -f $signkey ]; then
	echo "creating new token signing key"
	openssl genpkey -algorithm RSA -out $signkey.tmp -pkeyopt rsa_keygen_bits:4096
	mv $signkey.tmp $signkey
fi

# Kapi
secretkey="/kopano/ssl/kapid-pubs-secret.key"
if [ ! -f $secretkey ]; then
	openssl rand -out $secretkey.tmp -hex 64
	mv $secretkey.tmp $secretkey
fi

ls -l /kopano/ssl/*.pem
ls -l /kopano/ssl/*.key
