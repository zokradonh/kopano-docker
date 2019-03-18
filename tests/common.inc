#!/usr/bin/env bash

BASEDIR=$(dirname $0)
TESTDIR=$(realpath $BASEDIR/..)
IMAGE=${DOCKER_ORG:-joeblackwaslike}/dcgoss:latest
COMMAND=$(basename $0)

docker pull $IMAGE
docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $TESTDIR:/repo \
    -v /tmp:/tmp \
    $IMAGE \
    dcgoss $COMMAND "$@"
