#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# this is a kind of ugly hack to be able to source the env file
# this is sadly needed since postfix in https://github.com/tomav/docker-mailserver/ cannot deal with quoted values
tmpfile=$(mktemp /tmp/kopano-docker-env.XXXXXX)
cp ./.env "$tmpfile"
sed -i '/LDAP_QUERY_FILTER/s/^/#/g' "$tmpfile"
sed -i '/SASLAUTHD_LDAP_FILTER/s/^/#/g' "$tmpfile"
sed -i '/KCUNCOMMENT_LDAP_1/s/^/#/g' "$tmpfile"
sed -i '/KCCOMMENT_LDAP_1/s/^/#/g' "$tmpfile"

# shellcheck disable=SC1090
source "$tmpfile"

# update to latest docker for buildkit support
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce

# pull all base images once, as it will otherwise fail in travis
# shellcheck disable=SC2016
git ls-files | xargs awk -F' ' '/^FROM/ { print $2 }' | sort -n | uniq  | xargs --max-lines=1 docker pull
