#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEBUG=true
WORK_DIR=$(mktemp -d)
component=${1:-core}

function cleanup {
	rm -rf "$WORK_DIR"
	echo "Deleted temp working directory $WORK_DIR"
}

trap cleanup EXIT

cd "$WORK_DIR"
# shellcheck source=base/create-kopano-repo.sh
. "$DIR"/create-kopano-repo.sh
dl_and_package_community "$component"
