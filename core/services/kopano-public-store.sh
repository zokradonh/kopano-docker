#!/bin/bash

set -eo pipefail

exec dockerize \
	-wait tcp://localhost:236 \
	-timeout 360s \
	kopano-storeadm -h default: -P
