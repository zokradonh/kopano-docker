#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

HADOLINT_VERSION=1.17.1
DOCKER_COMPOSE_VERSION=1.23.2
TRIVY_VERSION=0.1.1
GOSS_VERSION=0.3.7
COMMANDER_VERSION=1.2.1

if ! command -v hadolint > /dev/null; then
	sudo curl -L "https://github.com/hadolint/hadolint/releases/download/v$HADOLINT_VERSION/hadolint-$(uname -s)-$(uname -m)" -o /usr/local/bin/hadolint
	sudo chmod +rx /usr/local/bin/hadolint
fi

if ! command -v docker-compose > /dev/null; then
	sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +rx /usr/local/bin/docker-compose
fi

if ! command -v trivy > /dev/null; then
	wget https://github.com/knqyf263/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
	sudo tar zxvf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz -C /usr/local/bin trivy
fi

if ! command -v goss > /dev/null; then
	sudo curl -L https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /usr/local/bin/goss
	sudo chmod +rx /usr/local/bin/goss
fi

if ! command -v dcgoss > /dev/null; then
	sudo curl -L https://raw.githubusercontent.com/fbartels/goss/dcgoss-v2/extras/dcgoss/dcgoss -o /usr/local/bin/dcgoss
	sudo chmod +rx /usr/local/bin/dcgoss
fi

if ! command -v commander > /dev/null; then
	sudo curl -L https://github.com/SimonBaeumer/commander/releases/download/v$COMMANDER_VERSION/commander-linux-amd64 -o /usr/local/bin/commander
	sudo chmod +rx /usr/local/bin/commander
fi

if ! command -v dccommander > /dev/null; then
	sudo curl -L https://raw.githubusercontent.com/fbartels/dccommander/master/dccommander -o /usr/local/bin/dccommander
	sudo chmod +rx /usr/local/bin/dccommander
fi

if ! command -v expect > /dev/null; then
	sudo apt update && sudo apt install -y expect
fi

if ! command -v pip > /dev/null; then
	sudo apt install -y python-pip
fi

if ! command -v yamllint > /dev/null; then
	sudo pip install --upgrade pip && sudo pip install yamllint
fi

if ! command -v npm > /dev/null; then
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	sudo apt install -y nodejs
fi

if ! command -v eclint > /dev/null; then
	npm install -g eclint
fi
