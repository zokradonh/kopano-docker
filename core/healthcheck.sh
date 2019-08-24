#!/bin/bash

set -e

case "$SERVICE_TO_START" in
server|dagent)
	goss -g /goss/goss_$SERVICE_TO_START.yaml validate --format json_oneline
	;;
*)
	echo "This service still needs a proper check"
	;;
esac

exit 0
