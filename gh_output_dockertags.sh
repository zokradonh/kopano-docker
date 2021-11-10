#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: version_dockertags.sh <repo> <component> [<distribution>] [<channel>] [<branch>]"
fi

function version_to_tags {
    repo=$1
    component=$2
    version=$3
    result="$repo/kopano_$component:$version"

    while [[ $version == *.* ]]; do \
        version=${version%.*} ; \
        result="$result,$repo/kopano_$component:$version"
    done

    echo $result
}

version="$( ./version.sh ${@:2} )"

echo "::set-output name=$2_version::$version"
echo "::set-output name=$2_version_tags::$(version_to_tags $1 $2 $version)"

