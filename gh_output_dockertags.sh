#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: version_dockertags.sh <component> [<distribution>] [<channel>] [<branch>]"
fi

function version_to_tags {
    version=$1
    result=$version

    while [[ $version == *.* ]]; do \
        version=${version%.*} ; \
        result="$result,$version"
    done

    echo $result
}

version="$( ./version.sh $@ )"

echo "::set-output name=$1_version::$version"
echo "::set-output name=$1_version_tags::$(version_to_tags $version)"

