#!/bin/sh

set -e

if [ $EMAIL = "self_signed" ]; then
	# do not use the '-host' option if using a self signed cert
	kwebd caddy -conf /etc/kweb.cfg -agree
else
	kwebd caddy -conf /etc/kweb.cfg -agree -host "$FQDN"
fi
