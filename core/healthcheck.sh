#!/bin/bash

set -e

case "$SERVICE_TO_START" in
server)
	kopano-cli --list-users
	exit 0
	;;
esac
