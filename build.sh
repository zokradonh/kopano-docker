#!/bin/bash

set -eu

branch="master"
buildcontext_base="https://github.com/zokradonh/kopano-docker.git#:"
networkname="buildproxy_net"
customBuildArgs=()
serial=""
component=""

function _usage()
{
    echo "Usage: build.sh -c core|webapp [-s serial] [-b master|final|pre-final] [-p buildcontext] [-n networkname] [[-a buildarg] ...]"
    echo "Example: build.sh -c core -s ABC123456789DEF -b final"
    echo "If no branch is specified, 'master' will be built by default."
    echo "If no buildcontext is specified, it will be built from git repository. Normally, you do not need to specify this."
    echo "If no networkname is specified, it will create and use a network named 'buildproxy_net'."
    echo "You can specify custom build args via e.g. -a KOPANO_CORE_REPOSITORY_URL=http://thisismy/url -a KOPANO_WEBAPP_REPOSITORY_URL=http://thisismy/url."
}

while getopts ":s:c:b:p:n:a:" opt; do
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
        n)
            networkname=$OPTARG
        ;;
        a)
            customBuildArgs[${#customBuildArgs[*]}]=$OPTARG
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

if [ ! -z "$serial" ]
then
    # get current version to brand and tag the image correctly
    currentVersion=$(curl -s -S -L https://serial:$serial@download.kopano.io/supported/$component:/$branch/Debian_9.0/Packages.gz |\
                        gzip -d | grep -A 8 "^Package: $mainpackage$" | awk '/Version/ { print $2 }')

    currentVersionDocker=$(echo $currentVersion | sed 's/+/plus/')

    # check existence of network
    isnetup=$(docker network ls | grep $networkname | wc -l)

    if [ $isnetup -eq 0 ]
    then
        echo "Missing build network. Creating network $networkname..."
        docker network create --attachable $networkname
    fi

    # check if buildproxy helper container is running
    isproxyup=$(docker ps | grep kopano_buildproxy | wc -l)

    if [ $isproxyup -eq 0 ]
    then
        echo "Build proxy container not runnning - now building..."
        docker build -t kopano_buildproxy ${buildcontext_base}repoproxy
        echo "Start buildproxy helper..."
        proxyContainerId=$(docker run --rm -ti -d -e KOPANO_SERIAL=$serial --network $networkname --network-alias buildproxy kopano_buildproxy)
    fi
else
    currentVersion="newest"
    currentVersionDocker="custom"
fi

# only tag the master branch with ":latest"
if [ "$branch" == "master" ]
then
    tagLatest="-t zokradonh/kopano_$component:latest"
else
    tagLatest=" "
fi

customBuildString=""
# prepare custom build args
for buildArg in "${customBuildArgs[@]}"
do
    customBuildString="$customBuildString --build-arg $buildArg"
done

# build it
echo "Start building kopano $component image version ($currentVersion)..."
docker build \
    --build-arg KOPANO_REPOSITORY_BRANCH=$branch \
    --build-arg KOPANO_${component^^}_VERSION=$currentVersion \
    $customBuildString \
    $tagLatest \
    -t zokradonh/kopano_$component:$currentVersionDocker \
    -t zokradonh/kopano_$component:latest-$branch \
    --network $networkname \
    ${buildcontext_base}${component}

# stop proxy container if we started it
if [ ! -z "$proxyContainerId" ]
then 
    docker stop $proxyContainerId
fi