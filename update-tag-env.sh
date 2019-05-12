#!/bin/bash

if ! hash reg; then
	echo "Please install reg in order to run this script."
	exit 1
fi

if [ ! -e ./.env ]; then
	echo "please run setup.sh first"
	exit 1
fi

# this is a kind of ugly hack to be able to source the env file
# this is sadly needed since postfix in https://github.com/tomav/docker-mailserver/ cannot deal with quotes values
tmpfile=$(mktemp /tmp/kopano-docker-env.XXXXXX)
cp ./.env "$tmpfile"
sed -i '/LDAP_QUERY_FILTER/s/^/#/g' "$tmpfile"
sed -i '/SASLAUTHD_LDAP_FILTER/s/^/#/g' "$tmpfile"
# shellcheck disable=SC1090
source "$tmpfile"

docker_tag_search () {
	image="$1"
	results=$(reg tags "$image" 2> /dev/null)
	echo "$results" | xargs -n1 | sort -ru | xargs
}

# define a default docker_repo in case its not in .env
docker_repo=${docker_repo:-zokradonh}

echo "Available tags in $docker_repo/kopano_core/: $(docker_tag_search $docker_repo/kopano_core)"
value_default="$CORE_VERSION"
read -r -p "Which tag do you want to use for Kopano Core components?
Please note that using an older version than the current one will result in failure to start. [$value_default]: " new_value
CORE_VERSION=${new_value:-$value_default}
sed -i "/^CORE_VERSION/c CORE_VERSION=$CORE_VERSION" ./.env

echo "Available tags in $docker_repo/kopano_webapp/: $(docker_tag_search $docker_repo/kopano_webapp)"
value_default="$WEBAPP_VERSION"
read -r -p "Which tag do you want to use for Kopano WebApp? [$value_default]: " new_value
WEBAPP_VERSION=${new_value:-$value_default}
sed -i "/^WEBAPP_VERSION/c WEBAPP_VERSION=$WEBAPP_VERSION" ./.env

if [ -e "$tmpfile" ]; then
	rm "$tmpfile"
fi
