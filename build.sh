#!/bin/bash

set -eu

branch="master"
buildcontext_base="https://github.com/zokradonh/kopano-docker.git#:"
customBuildArgs=()
serial=""
component=""
nocache=""

. ./base/create-kopano-repo.sh

function _usage()
{
    echo "Usage: build.sh -c core|webapp [-s serial] [-b master|final|pre-final] [-p buildcontext] [[-a buildarg] ...] [-i]"
    echo "Example: build.sh -c core -s ABC123456789DEF -b final"
    echo "-c   The Kopano component to be built."
    echo "-s   Provide serial if you want to build from supported repository."
    echo "-i   Do not use cache on docker build."
    echo "-b   If no branch is specified, 'master' will be built by default."
    echo "-p   If no buildcontext is specified, it will be built from git repository. Normally, you do not need to specify this."
    echo "-a   You can specify custom build args via e.g. -a ADDITIONAL_KOPANO_PACKAGES=kopano-migration-imap"
}

while getopts ":s:c:b:p:a:i" opt; do
    case $opt in
        s)
            serial=$OPTARG
        ;;
        c)
            component=${OPTARG,,}
        ;;
        b)
            branch=${OPTARG,,}
        ;;
        p)
            buildcontext_base=$OPTARG
        ;;
        a)
            customBuildArgs[${#customBuildArgs[*]}]=$OPTARG
        ;;
        i)
            nocache="--no-cache"
        ;;
        \?)
            _usage
            exit 1
        ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
        ;;
    esac
done

case "$component" in
    core)
        mainpackage="kopano-server"
        ;;
    webapp)
        mainpackage="kopano-webapp"
        ;;
    *)
        _usage
        exit 1
esac

customBuildString=""
# prepare custom build args
if [[ ${customBuildArgs[@]:+${customBuildArgs[@]}} ]];
then
    for buildArg in "${customBuildArgs[@]}"
    do
        customBuildString="$customBuildString --build-arg $buildArg"
    done
fi

if [ ! -z "$serial" ]
then

    # start build of supported kopano
    # get current version to brand and tag the image correctly
    currentVersion=$(curl -s -S -L "https://serial:$serial@download.kopano.io/supported/$component:/$branch/Debian_9.0/Packages.gz" |\
                        gzip -d | grep -A 8 "^Package: $mainpackage$" | awk '/Version/ { print $2 }')

    # webapp also needs core repository
    if [ "$component" == "webapp" ]
    then
        customBuildString="$customBuildString --build-arg KOPANO_CORE_REPOSITORY_URL=https://serial:$serial@download.kopano.io/supported/core:/$branch/Debian_9.0"
    fi

    echo "Start building supported kopano $component image version ($currentVersion)..."
    set -x
    # build it
    if docker build --pull \
                 --build-arg "KOPANO_${component^^}_REPOSITORY_URL=https://serial:$serial@download.kopano.io/supported/$component:/$branch/Debian_9.0" \
                 --build-arg RELEASE_KEY_DOWNLOAD=1 \
                 --build-arg "DOWNLOAD_COMMUNITY_PACKAGES=0" \
                 --build-arg "KOPANO_${component^^}_VERSION=$currentVersion" \
                 -t "zokradonh/kopano_$component:${currentVersion//+/plus}" \
                 -t "zokradonh/kopano_$component:latest-$branch" \
                 $nocache \
                 $customBuildString \
                 "${buildcontext_base}${component}"
    then 
        set +x
        echo "Please note that this image does include your serial. If you publish this image then your serial is exposed to public."
    fi
else
    # start build of community kopano

    
    if ! hash jq
    then
        echo "Please install jq in order to run this build script."
        exit 1
    fi

    # query community server by h5ai API
    filename=$(h5ai_query "$component")

    currentVersion=$(version_from_filename "$filename")

    echo "Start building community kopano $component image version ($currentVersion)..."
    set -x
    # build it
    docker build --pull \
                 -t "zokradonh/kopano_$component:${currentVersion//+/plus}" \
                 -t "zokradonh/kopano_$component:latest-$branch" \
                 -t "zokradonh/kopano_$component:latest" \
                 --build-arg "KOPANO_${component^^}_VERSION=$currentVersion" \
                 $nocache \
                 $customBuildString \
                 "${buildcontext_base}${component}"
    set +x
fi
