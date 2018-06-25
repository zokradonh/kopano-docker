#!/bin/bash

set -eu

if [ $# -lt 2 ]
then
    echo "Usage: build.sh core|webapp serial [master|final|pre-final] [buildcontext]"
    echo "Example: build.sh core ABC123456789DEF final"
    echo "If no branch is given, 'master' will be built by default."
    echo "If no buildcontext is given, it will build from git repository. Normally, you do not need to specify this."
    exit 1
fi

case "$1" in
    core)
        mainpackage="kopano-server"
        ;;
    webapp)
        mainpackage="kopano-webapp"
        ;;
    *)
        echo "Invalid component."
        exit 1
esac

component=${1,,}
serial=$2
branch=${3-master}
branch=${branch,,}
defaulturl="https://github.com/ZokRadonh/KopanoDocker.git#:"
buildcontext_base="${4-${defaulturl}}"

# get current version to brand and tag the image correctly
currentVersion=$(curl -s -S -L https://serial:$serial@download.kopano.io/supported/$component:/$branch/Debian_9.0/Packages.gz |\
                    gzip -d | grep -A 8 "^Package: $mainpackage$" | awk '/Version/ { print $2 }')

currentVersionDocker=$(echo $currentVersion | sed 's/+/plus/')

# check if buildproxy helper container is running
isproxyup=$(docker ps | grep kopano_buildproxy | wc -l)

if [ $isproxyup -eq 0 ]
then
    echo "Build proxy container not runnning - now building..."
    docker build -t kopano_buildproxy ${buildcontext_base}repoproxy
    echo "Start building proxy..."
    docker run --rm -ti -d -e KOPANO_SERIAL=$serial --network buildkopano_bnet --network-alias buildproxy kopano_buildproxy
fi

# only tag the master branch with ":latest"
if [ "$branch" == "master" ]
then
    tagLatest="-t zokradonh/kopano_$component:latest"
else
    tagLatest=" "
fi

# build it
echo "Start building kopano $component image version ($currentVersion)..."
docker build \
    --build-arg KOPANO_REPOSITORY_BRANCH=$branch \
    --build-arg KOPANO_${component^^}_VERSION=$currentVersion \
    $tagLatest \
    -t zokradonh/kopano_$component:$currentVersionDocker \
    -t zokradonh/kopano_$component:latest-$branch \
    --network buildkopano_bnet \
    ${buildcontext_base}${component}