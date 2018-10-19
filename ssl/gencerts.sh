#!/bin/sh

echo "Creating CA and Server certificates..."

easypki create --filename internalca --organizational-unit primary --expire 3650 --ca "Internal Kopano System"

mkdir -p /kopano/ssl/clients/
cp /kopano/easypki/internalca/certs/internalca.crt /kopano/ssl/ca.pem

for s in kserver kdagent kmonitor ksearch kspooler kwebapp
  do
    easypki create --ca-name internalca --organizational-unit $s --expire 3650 $s
    cp /kopano/easypki/internalca/keys/$s.key /kopano/ssl/$s.pem
    cat /kopano/easypki/internalca/certs/$s.crt >> /kopano/ssl/$s.pem
    openssl x509 -in /kopano/easypki/internalca/certs/$s.crt -pubkey -noout > /kopano/ssl/clients/$s-public.pem
done

ls -l /kopano/ssl/*.pem
