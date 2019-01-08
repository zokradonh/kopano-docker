#!/bin/sh
docker run \
	--rm -it \
	-u $(id -u ${USER}):$(id -g ${USER}) \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${PWD}/..:/kopano-docker/ \
	$(docker build -q .)

