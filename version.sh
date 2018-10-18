#!/bin/bash
if ! hash jq; then
	echo "Please install jq in order to run this build script."
	exit 1
fi

source base/create-kopano-repo.sh

component=${1:-core}

# query community server by h5ai API
filename=$(h5ai_query "$component")

currentVersion=$(version_from_filename "$filename")

echo $currentVersion
