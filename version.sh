#!/bin/bash

DEBUG=${DEBUG:-""}
tmpfile=${tmpfile:-""}

if ! command -v jq > /dev/null; then
	echo "Please install jq in order to run this build script."
	exit 1
fi

function finish {
	if [ -e "$tmpfile" ]; then
		rm "$tmpfile"
	fi
}
trap finish EXIT

source base/create-kopano-repo.sh

component=${1:-core}
distribution=${2:-Debian_9.0}
channel=${3:-community}
branch=${4:-""}

if [ -e ./.env ]; then
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
else
	tmpfile="undefined"
fi

case $component in
core)
	KOPANO_CORE_REPOSITORY_URL=${KOPANO_CORE_REPOSITORY_URL:-""}
	if [[ $KOPANO_CORE_REPOSITORY_URL == http* ]]; then
		version=$(curl --netrc-file ./apt_auth.conf --netrc-optional -m 1 -s -S -L "$KOPANO_CORE_REPOSITORY_URL"/Packages | grep -A2 "Package: kopano-server-packages")
		echo "${version##* }"
		exit
	fi
	;;
webapp)
	KOPANO_WEBAPP_REPOSITORY_URL=${KOPANO_WEBAPP_REPOSITORY_URL:-""}
	if [[ $KOPANO_WEBAPP_REPOSITORY_URL == http* ]]; then
		version=$(curl --netrc-file ./apt_auth.conf --netrc-optional -m 1 -s -S -L "$KOPANO_WEBAPP_REPOSITORY_URL"/Packages | grep -m1 -A1 "Package: kopano-webapp")
		echo "${version##* }"
		exit
	fi
	;;
zpush)
	KOPANO_ZPUSH_REPOSITORY_URL=${KOPANO_ZPUSH_REPOSITORY_URL:-"http://repo.z-hub.io/z-push:/final/Debian_9.0/"}
	if [[ $KOPANO_ZPUSH_REPOSITORY_URL == http* ]]; then
		version=$(curl -m 1 -s -S -L "$KOPANO_ZPUSH_REPOSITORY_URL"/Packages | grep -m2 -A2 "Package: z-push-kopano")
		echo "${version##* }"
		exit
	fi
	;;
meet)
	KOPANO_MEET_REPOSITORY_URL=${KOPANO_MEET_REPOSITORY_URL:-""}
	if [[ $KOPANO_MEET_REPOSITORY_URL == http* ]]; then
		version=$(curl --netrc-file ./apt_auth.conf --netrc-optional -m 1 -s -S -L "$KOPANO_MEET_REPOSITORY_URL"/Packages | grep -A2 "Package: kopano-meet-packages")
		echo "${version##* }"
		exit
	fi
	;;
kdav)
	git ls-remote --tags https://stash.kopano.io/scm/kc/kdav.git | awk -F/ '{ print $3 }' | tail -1 | sed 's/^.//'
	exit
esac

# query community server by h5ai API
filename=$(h5ai_query "$component" "$distribution" "$channel" "$branch")

currentVersion=$(version_from_filename "$filename")

versiontemp="${currentVersion//[^.]}"
# a valid version number has at least two dots. e.g. 1.2.3
if [ ${#versiontemp} -lt 2 ]; then
	echo "Malformed version received"
	exit 1
fi	

echo "$currentVersion"
