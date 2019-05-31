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

# function from https://stackoverflow.com/a/42790579/4754613
selectWithDefault() {

	local item i=0 numItems=$#

	# Print numbered menu items, based on the arguments passed.
	for item; do         # Short for: for item in "$@"; do
		printf '%s\n' "$((++i))) $item"
	done >&2 # Print to stderr, as `select` does.

	# Prompt the user for the index of the desired item.
	while :; do
		printf %s "${PS3-#? }" >&2 # Print the prompt string to stderr, as `select` does.
		read -r index
		# Make sure that the input is either empty or that a valid index was entered.
		[[ -z $index ]] && break  # empty input
		(( index >= 1 && index <= numItems )) 2>/dev/null || { echo "Invalid selection. Please try again." >&2; continue; }
		break
	done

	# Output the selected item, if any.
	[[ -n $index ]] && printf %s "${@: index:1}"
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
	set +e
	# shellcheck disable=SC2046
	new_value=$(selectWithDefault $(docker_tag_search "$docker_repo/$containername"))
	set -e
	return_value=${new_value:-$value_default}
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
