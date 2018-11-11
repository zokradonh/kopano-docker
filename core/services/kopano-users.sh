#!/bin/bash

set -eo pipefail

dockerize \
	-wait tcp://localhost:236 \
	-timeout 360s
while true; do kopano-cli --sync && sleep 3600; done
