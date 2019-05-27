#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if ! command -v reg > /dev/null; then
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
	echo "$results" | xargs -n1 | sort -ru
}

update_env_file () {
	varname="$1"
	varvalue="$2"
	if ! grep -q "$varname" ./.env; then
		echo "$varname=$varvalue" >> ./.env
	else
		sed -i "/$varname/c $varname=$varvalue" ./.env
	fi
}

tag_question () {
	containername="$1"
	value_default="$2"
	description="$3"
	echo "Which tag do you want to use for $description? [$value_default]"
	echo "Available tags in $docker_repo/$containername/: "
	# select does not work with an empty/default value https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt
	select new_value in $(docker_tag_search "$docker_repo/$containername"); do
	    if [[ -n $new_value ]]; then
	        return_value=${new_value:-$value_default}
    	else
	        return_value=$value_default
	    fi
		break
	done
}

echo "Please be aware that downgrading to an older version could result in failure to start!"

tag_question kopano_core "${CORE_VERSION:-latest}" "Kopano Core components"
update_env_file CORE_VERSION "$return_value"

tag_question kopano_webapp "${WEBAPP_VERSION:-latest}" "Kopano WebApp"
update_env_file WEBAPP_VERSION "$return_value"

tag_question kopano_web "${KWEB_VERSION:-latest}" "reverse proxy"
update_env_file KWEB_VERSION "$return_value"

tag_question kopano_zpush "${ZPUSH_VERSION:-latest}" "Z-Push"
update_env_file ZPUSH_VERSION "$return_value"

tag_question kopano_kdav "${KDAV_VERSION:-latest}" "kDAV"
update_env_file KDAV_VERSION "$return_value"

tag_question kopano_konnect "${KONNECT_VERSION:-latest}" "Kopano Konnect"
update_env_file KONNECT_VERSION "$return_value"

tag_question kopano_kwmserver "${KWM_VERSION:-latest}" "Kopano Kwmserver"
update_env_file KWM_VERSION "$return_value"

tag_question kopano_meet "${MEET_VERSION:-latest}" "Kopano Meet"
update_env_file MEET_VERSION "$return_value"

tag_question kopano_scheduler "${SCHEDULER_VERSION:-latest}" "Scheduler"
update_env_file SCHEDULER_VERSION "$return_value"

tag_question kopano_ssl "${SSL_VERSION:-latest}" "SSL helper container"
update_env_file SSL_VERSION "$return_value"

tag_question kopano_ldap "${LDAP_VERSION:-latest}" "LDAP container"
update_env_file LDAP_VERSION "$return_value"

if [ -e "$tmpfile" ]; then
	rm "$tmpfile"
fi
