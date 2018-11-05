#!/bin/bash

case "$SERVICE_TO_START" in
server)
	dockerize \
	-wait tcp://localhost:237 \
	([ -f /kopano/data/.user-sync ] || kopano-cli --sync; touch /kopano/data/.user-sync)
	exit 0
	;;
esac
