#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

COMMANDER_VERSION=2.1.0
DOCKER_COMPOSE_VERSION=1.25.5
GOSS_VERSION=0.3.11
HADOLINT_VERSION=1.23.0
REG_VERSION=0.16.1
SHELLCHECK_VERSION=0.7.1

progname=$(basename "$0")
tempdir=$(mktemp -d "/tmp/$progname.XXXXXX")
function cleanup() {
	rm -rf "$tempdir"
}
trap cleanup INT EXIT

cd "$tempdir"

if ! command -v hadolint > /dev/null; then
	sudo curl -L "https://github.com/hadolint/hadolint/releases/download/v$HADOLINT_VERSION/hadolint-$(uname -s)-$(uname -m)" -o /usr/local/bin/hadolint
	sudo chmod +rx /usr/local/bin/hadolint
fi

if ! command -v docker-compose > /dev/null; then
	sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +rx /usr/local/bin/docker-compose
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

if ! command -v reg  > /dev/null; then
	sudo curl -L https://github.com/genuinetools/reg/releases/download/v$REG_VERSION/reg-linux-amd64 -o /usr/local/bin/reg
	sudo chmod +rx /usr/local/bin/reg
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
	npm config set prefix ~
fi

if ! command -v eclint > /dev/null; then
	npm install eclint -g
fi

if ! command -v shellcheck > /dev/null; then
	wget "https://github.com/koalaman/shellcheck/releases/download/v$SHELLCHECK_VERSION/shellcheck-v$SHELLCHECK_VERSION.linux.x86_64.tar.xz"
	tar -xf shellcheck-v*.linux.x86_64.tar.xz
	sudo mv shellcheck-v*/shellcheck /usr/local/bin/
fi

if ! command -v jq > /dev/null; then
	sudo apt install -y jq
fi
