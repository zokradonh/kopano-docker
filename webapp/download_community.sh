#!/bin/bash

# take component as first argument and fallback to core if none given
component=${1:-core}

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# query community server by h5ai API
filename=$(curl -s -S -L -d "action=get&items%5Bhref%5D=%2Fcommunity%2F$component%3A%2F&items%5Bwhat%5D=1" -H \
                "Accept: application/json" https://download.kopano.io/community/ | jq '.items[].href' | \
                grep 'Debian_9.0-all\|Debian_9.0-amd64' | sed 's#"##g' | sed "s#/community/$component:/##")

if [ -z "${filename// }" ]; then
	echo "unknown component"
	exit 1
fi

filename=$(urldecode "$filename")

# download & extract packages
curl -s -S -L -o "$filename" https://download.kopano.io/community/"$component":/"${filename}"

tar xf "$filename"

# save disk space
rm "$filename"

# prepare directory to be apt source
apt-ftparchive packages "${filename%.tar.gz}" | gzip -9c > Packages.gz
