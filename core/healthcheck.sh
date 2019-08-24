#!/bin/bash

set -ex

case "$SERVICE_TO_START" in
server)
	goss -g /goss/goss_server.yml validate
	;;
dagent)
	goss -g /goss/goss_dagent.yml validate
	;;
esac

exit 0
