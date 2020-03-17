#!/bin/sh

set -e

# Only configure services and wait for sane evironment if AUTOCONFIG env is set
if [ "$AUTOCONFIG" = "yes" ]; then
	# services need to be aware of the machine-id
	dockerize \
		-wait file:///etc/machine-id \
		-wait file:///var/lib/dbus/machine-id
fi

exec kwebd caddy -conf /etc/kweb.cfg -agree
