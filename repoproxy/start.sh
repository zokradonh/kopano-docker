#!/bin/ash

KOPANO_USER=serial

export KOPANO_REPOSITORY_BASE_URL="https://download.kopano.io/"

export B64_CREDS=$(echo "$KOPANO_USER:$KOPANO_SERIAL" | base64)

# inject the secrets into config file
cat /buildproxy/default.conf | envsubst > /etc/nginx/conf.d/default.conf

# run reverse proxy
exec nginx -g "daemon off;"