#!/bin/bash

set -eu
#set -x

function urldecode { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

function version_from_filename {
    echo "$1" | sed -r 's#[a-z]+-([0-9_.+]+)-.*#\1#'
}

function h5ai_query {
    component=${1:-core}
    distribution=${2:-Debian_9.0}

    filename=$(curl -s -S -L -d "action=get&items%5Bhref%5D=%2Fcommunity%2F$component%3A%2F&items%5Bwhat%5D=1" -H \
                "Accept: application/json" https://download.kopano.io/community/ | jq '.items[].href' | \
                grep "$distribution-all\|$distribution-amd64" | sed 's#"##g' | sed "s#/community/$component:/##")

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

    # query community server by h5ai API
    filename=$(h5ai_query "$component" "$distribution")

    # download & extract packages
    curl -s -S -L -o "$filename" https://download.kopano.io/community/"$component":/"${filename}"
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
