#!/bin/sh
if [ ! "$(id -u)" -eq 0 ]; then
	echo "This script may need to be run as root to be able to use docker/docker-compose through it."
fi

cd "$(dirname "$0")" || exit

docker build .

docker run \
	--rm -it \
	-u "$(id -u)":"$(id -g)" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "$(pwd)"/..:/kopano-docker/ \
	"$(docker build -q .)" "$@"
