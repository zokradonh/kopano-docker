#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if ! command -v reg > /dev/null; then
	echo "Please install reg to list available tags. You can only press enter when being asked for a tag."
fi

if [ ! -e ../.env ]; then
	echo "please run setup.sh first"
	exit 1
fi

# this is a kind of ugly hack to be able to source the env file
# this is sadly needed since postfix in https://github.com/tomav/docker-mailserver/ cannot deal with quoted values
tmpfile=$(mktemp /tmp/kopano-docker-env.XXXXXX)
cp ../.env "$tmpfile"
sed -i '/LDAP_QUERY_FILTER/s/^/#/g' "$tmpfile"
sed -i '/SASLAUTHD_LDAP_FILTER/s/^/#/g' "$tmpfile"
sed -i '/KCUNCOMMENT_LDAP_1/s/^/#/g' "$tmpfile"
sed -i '/KCCOMMENT_LDAP_1/s/^/#/g' "$tmpfile"

# shellcheck disable=SC1090
source "$tmpfile"

fqdn_to_dn() {
	printf 'dc=%s' "$1" | sed -E 's/\./,dc=/g'
}

random_string() {
	hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom
}

docker_tag_search() {
	image="$1"
	results=$(reg tags "$image" 2> /dev/null)
	echo "$results" | xargs -n1 | sort --version-sort -ru
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

update_env_file() {
	varname="$1"
	varvalue="$2"
	if ! grep -q "$varname" ../.env; then
		echo "$varname=$varvalue" >> ../.env
	else
		sed -i "/$varname/c $varname=$varvalue" ../.env
	fi
}

tag_question() {
	containername="$1"
	value_default="$2"
	description="$3"
	echo "Which tag do you want to use for $description? [$value_default]"
	echo "Available tags in $containername: "
	set +e # do not exit when new_value is empty
	# shellcheck disable=SC2046
	new_value=$(selectWithDefault $(docker_tag_search "$containername"))
	set -e
	return_value=${new_value:-$value_default}
}

tag_question owncloud/server "${OWNCLOUD_VERSION:-latest}" "Owncloud"
update_env_file OWNCLOUD_VERSION "$return_value"
update_env_file OWNCLOUD_DB_USERNAME owncloud
update_env_file OWNCLOUD_DB_PASSWORD "$(random_string)"
update_env_file OWNCLOUD_ADMIN_USERNAME admin
update_env_file OWNCLOUD_ADMIN_PASSWORD "$(random_string)"
update_env_file MARIADB_ROOT_PASSWORD "$(random_string)"

echo "Setup complete"

if [ -e "$tmpfile" ]; then
	rm "$tmpfile"
fi
