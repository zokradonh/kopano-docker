#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# update to latest docker for buildkit support
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce

# get base images to pull, as it will otherwise fail in travis
# git ls-files | xargs awk -F' ' '/^FROM/ { print $2 }' | sort -n | uniq | xargs --max-lines=1 docker pull

#docker pull alpine:3.9
#docker pull composer:1.8
#docker pull debian:stretch
#docker pull docker:19.03
docker pull docker/dockerfile:1.0-experimental
docker pull docker.io/docker/dockerfile-copy:v0.1.9
#docker pull halverneus/static-file-server:v1.5.2
#docker pull kopano/konnectd:latest
#docker pull kopano/kwebd:latest
#docker pull kopano/kwmserverd:latest
#docker pull osixia/openldap:latest
#docker pull zokradonh/kopano_base
#docker pull zokradonh/kopano_core
#docker pull zokradonh/kopano_ldap
#docker pull zokradonh/kopano_php
#docker pull zokradonh/kopano_scheduler
#docker pull zokradonh/kopano_webapp
