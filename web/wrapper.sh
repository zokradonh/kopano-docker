#!/bin/sh

set -e

if [ "$EMAIL" = "self_signed" ] || [ "$EMAIL" = "off" ]; then
	# do not use the '-host' option if using a self signed cert
	exec kwebd caddy -conf /etc/kweb.cfg -agree
else
	exec kwebd caddy -conf /etc/kweb.cfg -agree -host "$FQDN"
fi
