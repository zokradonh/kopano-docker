#!/bin/sh

set -e

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

exec kwebd caddy -conf /etc/kweb.cfg -agree
