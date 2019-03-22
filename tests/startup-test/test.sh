#!/bin/sh
# waits for key events in various containers
# e.g. kopano_server:236 signals succesful start of kopano-server process
exec dockerize \
	-wait file://var/run/kopano/grapi/notify.sock \
	-wait http://kopano_konnect:8777/.well-known/openid-configuration \
	-wait tcp://kopano_server:236 \
	-wait tcp://kopano_server:237 \
	-wait tcp://kopano_gateway:143 \
	-wait tcp://kopano_ical:8080 \
	-wait tcp://kopano_webapp:80 \
	-wait tcp://kopano_zpush:80 \
	-wait file://var/run/kopano/server.sock \
	-wait tcp://"${KCCONF_SERVER_MYSQL_HOST}":3306 \
	-timeout 120s
