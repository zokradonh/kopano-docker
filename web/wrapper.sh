#!/bin/sh

set -e

# services need to be aware of the machine-id
if [ "$AUTOCONFIG" = "yes" ]; then
	dockerize \
		-wait file:///etc/machine-id \
		-wait file:///var/lib/dbus/machine-id
fi

exec kwebd caddy -conf /etc/kweb.cfg -agree
