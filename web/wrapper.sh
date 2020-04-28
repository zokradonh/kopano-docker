#!/bin/sh

set -e

# define default value for email value
EMAIL="${EMAIL:-off}"
# use same value for certificate if not specified otherwise
CERTIFICATE="${CERTIFICATE:-$EMAIL}";

# services need to be aware of the machine-id
dockerize \
	-wait file:///etc/machine-id \
	-wait file:///var/lib/dbus/machine-id

exec kwebd caddy -conf /etc/kweb.cfg -agree
