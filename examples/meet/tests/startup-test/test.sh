#!/bin/bash

set -ex

# waits for key events in various containers
# e.g. kopano_server:236 signals successful start of kopano-server process
dockerize \
	-wait file:///var/run/kopano/grapi/notify.sock \
	-wait http://kopano_konnect:8777/.well-known/openid-configuration \
	-wait tcp://kopano_kwmserver:8778 \
	-wait tcp://kopano_meet:9080 \
	-wait tcp://web:2015 \
	-timeout 30s
