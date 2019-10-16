#!/bin/bash

set -eu

mysql=${mysql:?}

function create_user_and_database() {
	local database=$1
	echo "  Creating database '$database'"
	echo "CREATE DATABASE IF NOT EXISTS ${database};" | "${mysql[@]}"
	echo "GRANT ALL PRIVILEGES ON ${database}.* TO '${MYSQL_USER}';" | "${mysql[@]}"
}

if [ -n "$MYSQL_ADDITIONAL_DATABASES" ]; then
	echo "Multiple database creation requested: $MYSQL_ADDITIONAL_DATABASES"
	for db in $(echo "$MYSQL_ADDITIONAL_DATABASES" | tr ',' ' '); do
		create_user_and_database "$db"
	done
	echo "Additional databases created"
fi
