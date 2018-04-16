#!/bin/bash

set -eu # unset variables are errors & non-zero return values exit the whole script

mkdir -p /kopano/data/attachments /var/run/kopano

echo "Create /etc/kopano/ldap.cfg and prepare" | ts
cp /usr/share/doc/kopano/example-config/ldap.cfg /etc/kopano/ldap.cfg
sed -e "s|^\s*!include /usr/share/kopano/ldap.openldap.cfg|#!include /usr/sharekopano/ldap.openldap.cfg|" \
    -e "s|#!include /usr/share/kopano/ldap.active-directory.cfg|!include /usr/share/kopano/ldap.active-directory.cfg|" \
    -i /etc/kopano/ldap.cfg

echo "Configure server core" | ts
/usr/bin/python3 /kopano/configure.py

echo "Set config ownership" | ts
chown -R kopano:kopano /kopano/data /run /tmp

echo "Clean old pid files and sockets" | ts
rm -f /var/run/kopano/*

exec /usr/sbin/kopano-server -F
