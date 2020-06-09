#!/bin/bash

set -ex

# waits for key events in various containers
# e.g. kopano_server:236 signals successful start of kopano-server process
dockerize \
	-wait http://kopano_konnect:8777/.well-known/openid-configuration \
	-wait http://kopano_meet:9080/meet \
	-wait tcp://"${KCCONF_SERVER_MYSQL_HOST}":3306 \
	-wait tcp://kopano_dagent:2003 \
	-wait tcp://kopano_gateway:143 \
	-wait tcp://kopano_ical:8080 \
	-wait tcp://kopano_kapi:8039 \
	-wait tcp://kopano_kwmserver:8778 \
	-wait tcp://kopano_server:236 \
	-wait tcp://kopano_server:237 \
	-wait tcp://kopano_webapp:9080 \
	-wait tcp://kopano_zpush:80 \
	-wait tcp://web:2015 \
	-timeout 120s
# TODO add check for port 8779 of kwmbridge

# until goss is part of the general testsuite check goss for kopano-server here as well
docker exec kopano_server goss -g /kopano/goss/server/goss.yaml validate

# make sure the public store exists
docker exec kopano_server kopano-storeadm -h default: -P || true

docker exec kopano_server kopano-admin --sync
docker exec kopano_server kopano-cli --list-users
docker exec kopano_server kopano-storeadm -O # list users without a store
docker exec kopano_server kopano-admin -l
docker exec kopano_zpush z-push-admin -a list
docker exec kopano_zpush z-push-gabsync -a sync

# will print nothing if store exists and fail if it doesn't
docker exec kopano_server kopano-admin --details user1 | grep -q "^Store GUID:"
