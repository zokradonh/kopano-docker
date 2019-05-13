#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

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

# define a default docker_repo in case its not in .env
docker_repo=${docker_repo:-zokradonh}

docker_tag_search () {
	image="$1"
	results=$(reg tags "$image" 2> /dev/null)
	echo "$results" | xargs -n1 | sort -ru | xargs
}

update_env_file () {
	varname="$1"
	varvalue="$2"
	if ! grep -q "$varname" ./.env; then
		echo "$varname=$varvalue" >> ./.env
	else
		sed -i "/^$varname/c $varname=$varvalue" ./.env
	fi
}

tag_question () {
	containername="$1"
	value_default="$2"
	description="$3"
	echo "Available tags in $docker_repo/$containername/: $(docker_tag_search "$docker_repo/$containername")"
	read -r -p "Which tag do you want to use for $description? [$value_default]: " new_value
	echo ${new_value:-$value_default}
}

echo "Please be aware that downgrading to an older version could result in failure to start!"

# TODO this currently puts the full echo into the .env file
update_env_file CORE_VERSION $(tag_question kopano_core $CORE_VERSION "Kopano Core components")

exit

echo "Available tags in $docker_repo/kopano_core/: $(docker_tag_search "$docker_repo"/kopano_core)"
value_default="$CORE_VERSION"
read -r -p "Which tag do you want to use for Kopano Core components? [$value_default]: " new_value
CORE_VERSION=${new_value:-$value_default}

echo "Available tags in $docker_repo/kopano_webapp/: $(docker_tag_search "$docker_repo"/kopano_webapp)"
value_default="$WEBAPP_VERSION"
read -r -p "Which tag do you want to use for Kopano WebApp? [$value_default]: " new_value
WEBAPP_VERSION=${new_value:-$value_default}
update_env_file WEBAPP_VERSION $WEBAPP_VERSION

ZPUSH_VERSION
KDAV_VERSION
KONNECT_VERSION
KWM_VERSION
MEET_VERSION
SCHEDULER_VERSION

echo "Available tags in $docker_repo/kopano_web/: $(docker_tag_search "$docker_repo"/kopano_web)"
value_default=${KWEB_VERSION:-latest}
read -r -p "Which tag do you want to use for the web container? [$value_default]: " new_value
KWEB_VERSION=${new_value:-$value_default}
update_env_file KWEB_VERSION $KWEB_VERSION

if [ -e "$tmpfile" ]; then
	rm "$tmpfile"
fi