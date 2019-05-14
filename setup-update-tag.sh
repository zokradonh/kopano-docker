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
	return_value=${new_value:-$value_default}
}

echo "Please be aware that downgrading to an older version could result in failure to start!"

tag_question kopano_core $CORE_VERSION "Kopano Core components"
update_env_file CORE_VERSION $return_value

tag_question kopano_webapp $WEBAPP_VERSION "Kopano WebApp"
update_env_file WEBAPP_VERSION $return_value

tag_question kopano_web $KWEB_VERSION "reverse proxy"
update_env_file KWEB_VERSION $return_value

tag_question kopano_zpush $ZPUSH_VERSION "Z-Push"
update_env_file ZPUSH_VERSION $return_value

tag_question kopano_kdav $KDAV_VERSION "KDav"
update_env_file KDAV_VERSION $return_value

tag_question kopano_konnect $KONNECT_VERSION "Kopano Konnect"
update_env_file KONNECT_VERSION $return_value

tag_question kopano_kwmserver $KWM_VERSION "Kopano Kwmserver"
update_env_file KWM_VERSION $return_value

tag_question kopano_meet $MEET_VERSION "Kopano Meet"
update_env_file MEET_VERSION $return_value

tag_question kopano_scheduler ${SCHEDULER_VERSION:-latest} "Scheduler"
update_env_file SCHEDULER_VERSION $return_value

if [ -e "$tmpfile" ]; then
	rm "$tmpfile"
fi