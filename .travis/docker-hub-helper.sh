#!/bin/bash
# bash .travis/docker-hub-helper.sh base

set -euo pipefail
IFS=$'\n\t'

# this is a kind of ugly hack to be able to source the env file
# this is sadly needed since postfix in https://github.com/tomav/docker-mailserver/ cannot deal with quoted values
tmpfile=$(mktemp /tmp/kopano-docker-env.XXXXXX)
cp ./.env "$tmpfile"
sed -i '/LDAP_QUERY_FILTER/s/^/#/g' "$tmpfile"
sed -i '/SASLAUTHD_LDAP_FILTER/s/^/#/g' "$tmpfile"
# shellcheck disable=SC1090
source "$tmpfile"

docker_repo=${docker_repo:-zokradonh}
docker_login=${docker_login:-""}
docker_pwd=${docker_pwd:-""}

if [ -z "$docker_login" ]; then
  docker_login="$(<~/.docker-account-user)"
fi

if [ -z "$docker_pwd" ]; then
  docker_pwd="$(<~/.docker-account-pwd)"
fi

image=${1:-""}
if [ -z "$image" ]; then
  echo "ERROR: You must specify an image to modify."
  exit 1
fi

# below code is based on https://github.com/moikot/golang-dep/blob/aab3ea8462a19407544f1ce9daa11c3f0924394c/.travis/push.sh
#
# Pushes README.md content to Docker Hub.
#
# $1 - The image name.
# $2 - The JWT.
#
# Examples:
#
#   push_readme "foo/bar" "token"
#
push_readme() {
  declare -r image="${1}"
  declare -r token="${2}"
  declare -r readme="${3}"

  local code
  code=$(jq -n --arg msg "$(<"${readme}")" \
    '{"registry":"registry-1.docker.io","full_description": $msg }' | \
        curl -s -o /dev/null  -L -w "%{http_code}" \
           https://cloud.docker.com/v2/repositories/"${image}"/ \
           -d @- -X PATCH \
           -H "Content-Type: application/json" \
           -H "Authorization: JWT ${token}")

  if [[ "${code}" = "200" ]]; then
    printf "Successfully pushed README to Docker Hub"
  else
    printf "Unable to push README to Docker Hub, response code: %s\n" "${code}"
    exit 1
  fi

  local code
  code=$(jq -n --arg msg "$(head -n 1 "${readme}" | cut -d' ' -f2-)" \
    '{"registry":"registry-1.docker.io","description": $msg }' | \
        curl -s -o /dev/null  -L -w "%{http_code}" \
           https://cloud.docker.com/v2/repositories/"${image}"/ \
           -d @- -X PATCH \
           -H "Content-Type: application/json" \
           -H "Authorization: JWT ${token}")

  if [[ "${code}" = "200" ]]; then
    printf "Successfully pushed description to Docker Hub"
  else
    printf "Unable to push description to Docker Hub, response code: %s\n" "${code}"
    exit 1
  fi
}

# Login into Docker repository
#echo "$docker_pwd" | docker login -u "$docker_login" --password-stdin

token=$(curl -s -X POST \
-H "Content-Type: application/json" \
-d '{"username": "'"$docker_login"'", "password": "'"$docker_pwd"'"}' \
https://hub.docker.com/v2/users/login/ | jq -r .token)

push_readme "${docker_repo}"/kopano_"${image}" "${token}" "${image}"/README.md

if [ -e "$tmpfile" ]; then
  rm "$tmpfile"
fi
