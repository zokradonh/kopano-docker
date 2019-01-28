#!/bin/sh
if [ ! $(id -u) -eq 0 ]; then
	echo "This script may need to be run as root to be able to use docker/docker-compose through it."
fi
docker run \
	--rm -it \
	-u $(id -u ${USER}):$(id -g ${USER}) \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${PWD}/..:/kopano-docker/ \
	$(docker build -q .) $@
