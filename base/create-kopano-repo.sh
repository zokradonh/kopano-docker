#!/bin/bash

set -eu
[ "$DEBUG" ] && set -x

function urldecode { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

function version_from_filename {
	echo "$1" | awk -F"-" '{print $2}'
}

function h5ai_query {
	component=${1:-core}
	distribution=${2:-Debian_9.0}
	channel=${3:-community} # could either be community, supported or limited
	branch=${4:-""} # could either be empty, "master/tarballs", "pre-final/tarballs" or "final/tarballs"

	filename=$(curl -s -XPOST "https://download.kopano.io/$channel/?action=get&items\[href\]=/$channel/$component:/$branch&items\[what\]=1" | \
			jq -r '.items[].href' | \
			grep "$distribution-all\|$distribution-amd64" | sed "s#/$channel/$component:/##")

	if [ -z "${filename// }" ]; then
		echo "unknown component"
		exit 1
	fi

	filename=$(urldecode "$filename")
	echo "$filename"
}

function dl_and_package_community {
	# take component as first argument and fallback to core if none given
	component=${1:-core}
	distribution=${2:-Debian_9.0}
	channel=${3:-community}
	branch=${4:-""}

	# query community server by h5ai API
	filename=$(h5ai_query "$component" "$distribution" "$channel" "$branch")

	# download & extract packages
	curl -s -S -L -o "$filename" https://download.kopano.io/"$channel"/"$component":/"${filename}"
	tar xf "$filename"

	# save buildversion
	currentVersion=$(version_from_filename "$filename")
	echo "$component-$currentVersion" >> /kopano/buildversion

	# save disk space
	rm "$filename"

	mv "${filename%.tar.gz}" "$component"

	# prepare directory to be apt source
	cd "$component"
	apt-ftparchive packages . | gzip -9c > Packages.gz
	cd ".."
}
