#!/bin/bash

if [ $# -lt 2 ]
then
    echo "Usage: master-push.sh core|webapp version"
    echo "Example: master-push.sh core 3.4.17.1565plus895.1"
    exit 1
fi

component=$1
version=$2

docker push zokradonh/kopano_${component}:latest
docker push zokradonh/kopano_${component}:latest-master
docker push zokradonh/kopano_${component}:$version
