#!/bin/bash

set -e

case "$SERVICE_TO_START" in
server|dagent)
	goss -g /kopano/goss/$SERVICE_TO_START/goss.yaml validate --format json_oneline
	;;
*)
	echo "This service still needs a proper check"
	;;
esac

exit 0
