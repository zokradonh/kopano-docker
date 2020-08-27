#!/bin/sh

set -e

# allow helper commands given by "docker-compose run"
if [ $# -gt 0 ]; then
	exec "$@"
	exit
fi

export CADDYPATH="$KOPANO_KWEB_ASSETS_PATH"

# services need to be aware of the machine-id
if [ "$AUTOCONFIGURE" = true ]; then
	dockerize \
		-wait file:///etc/machine-id \
		-wait file:///var/lib/dbus/machine-id
fi

exec "$EXE" caddy -conf /etc/kweb.cfg -agree
