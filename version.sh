#!/bin/bash
if ! hash jq; then
	echo "Please install jq in order to run this build script."
	exit 1
fi

source base/create-kopano-repo.sh

component=${1:-core}
COMPONENT=$(echo $component | tr a-z A-Z)

if [ -e ./env ]; then
	source ./env
fi

case $component in
core)
	KOPANO_CORE_REPOSITORY_URL=${KOPANO_CORE_REPOSITORY_URL:-""}
	if [[ $KOPANO_CORE_REPOSITORY_URL == http* ]]; then
		version=$(curl -s -S -L $KOPANO_CORE_REPOSITORY_URL/Packages | grep -A2 "Package: kopano-server-packages")
		echo "${version##* }"
		exit
	fi
	;;
webapp)
	KOPANO_WEBAPP_REPOSITORY_URL=${KOPANO_WEBAPP_REPOSITORY_URL:-""}
	if [[ $KOPANO_WEBAPP_REPOSITORY_URL == http* ]]; then
		version=$(curl -s -S -L $KOPANO_WEBAPP_REPOSITORY_URL/Packages | grep -m1 -A1 "Package: kopano-webapp")
		echo "${version##* }"
		exit
	fi
	;;
zpush)
	KOPANO_ZPUSH_REPOSITORY_URL=${KOPANO_ZPUSH_REPOSITORY_URL:-"http://repo.z-hub.io/z-push:/final/Debian_9.0/"}
	if [[ $KOPANO_ZPUSH_REPOSITORY_URL == http* ]]; then
		version=$(curl -s -S -L $KOPANO_ZPUSH_REPOSITORY_URL/Packages | grep -m2 -A2 "Package: z-push-kopano")
		echo "${version##* }"
		exit
	fi
	;;
esac

# query community server by h5ai API
filename=$(h5ai_query "$component")

currentVersion=$(version_from_filename "$filename")

echo $currentVersion
