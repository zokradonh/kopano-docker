#!/bin/sh
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi
docker run \
	--rm -it \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${PWD}/..:/kopano-docker/ \
	$(docker build -q .)

