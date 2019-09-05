#!/bin/bash

set -e

fqdn_to_dn() {
	printf 'dc=%s' "$1" | sed -E 's/\./,dc=/g'
}

random_string() {
	hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom
}

LANG_OPTIONS=("de-at" "de-ch" "de-de" "en" "en-gb" "es" "fr" "it" "nl" "pl-pl")
PLUGIN_OPTIONS=("contactfax" "desktopnotifications" "filepreviewer" "files" "filesbackend-smb" "filesbackend-owncloud" "folderwidgets" "gmaps" "intranet" "mattermost" "mdm" "pimfolder" "quickitems" "smime" "titlecounter" "webappmanual" "zdeveloper")

lang_menu() {
	echo "Available options:"
	for i in "${!LANG_OPTIONS[@]}"; do
		printf "%3d%s) %s\n" $((i+1)) "${lang_choices[i]:- }" "${LANG_OPTIONS[i]}"
	done
	[[ "$msg" ]] && echo "$msg"; :
}

plugin_menu() {
	echo "Available options:"
	for i in "${!PLUGIN_OPTIONS[@]}"; do
		printf "%3d%s) %s\n" $((i+1)) "${plugin_choices[i]:- }" "${PLUGIN_OPTIONS[i]}"
	done
	[[ "$msg" ]] && echo "$msg"; :
}

docker_tag_search () {
	image="$1"
	results=$(reg tags "$image" 2> /dev/null)
	echo "$results" | xargs -n1 | sort --version-sort -ru | xargs
}

echo "Creating individual env files for containers (if they do not exist already)"
for dockerenv in ldap password-self-service mail db kopano_ssl kopano_server kopano_webapp kopano_zpush kopano_grapi kopano_kapi kopano_dagent kopano_spooler kopano_gateway kopano_ical kopano_monitor kopano_scheduler kopano_search kopano_konnect kopano_kwmserver kopano_meet; do
	touch ./"$dockerenv".env
done

if [ ! -e ./.env ]; then
	PRINT_SETUP_SUCCESS=""

	echo "Creating an .env file for you"

	# if the optional https://github.com/genuinetools/reg is installed this will list available tags
	if command -v reg > /dev/null; then
		echo "Available tags in zokradonh/kopano_core/: $(docker_tag_search zokradonh/kopano_core)"
	fi
	value_default=latest
	read -r -p "Which tag do you want to use for Kopano Core components? [$value_default]: " new_value
	CORE_VERSION=${new_value:-$value_default}

	if command -v reg > /dev/null; then
		echo "Available tags in https://hub.docker.com/r/zokradonh/kopano_webapp/: $(docker_tag_search zokradonh/kopano_webapp)"
	fi
	value_default=latest
	read -r -p "Which tag do you want to use for Kopano WebApp? [$value_default]: " new_value
	WEBAPP_VERSION=${new_value:-$value_default}

	if command -v reg > /dev/null; then
		echo "Available tags in https://hub.docker.com/r/zokradonh/kopano_zpush/: $(docker_tag_search zokradonh/kopano_zpush)"
	fi
	value_default=latest
	read -r -p "Which tag do you want to use for Z-Push? [$value_default]: " new_value
	ZPUSH_VERSION=${new_value:-$value_default}

	if command -v reg > /dev/null; then
		echo "Available tags in https://hub.docker.com/r/zokradonh/kopano_konnect/: $(docker_tag_search zokradonh/kopano_konnect)"
	fi
	value_default=latest
	read -r -p "Which tag do you want to use for Kopano Konnect? [$value_default]: " new_value
	KONNECT_VERSION=${new_value:-$value_default}

	value_default=latest
	read -r -p "Which tag do you want to use for Kopano Kwmserver? [$value_default]: " new_value
	KWM_VERSION=${new_value:-$value_default}

	value_default=latest
	read -r -p "Which tag do you want to use for Kopano Meet? [$value_default]: " new_value
	MEET_VERSION=${new_value:-$value_default}

	value_default=latest
	read -r -p "Which tag do you want to use for Kopano kDAV? [$value_default]: " new_value
	KDAV_VERSION=${new_value:-$value_default}

	value_default="Kopano Demo"
	read -r -p "Name of the Organisation for LDAP [$value_default]: " new_value
	LDAP_ORGANISATION=${new_value:-$value_default}

	value_default="kopano.demo"
	read -r -p "FQDN to be used (for reverse proxy).
	Hint: use port 2015 in case port 443 is already in use on the system.
	[$value_default]: " new_value
	FQDN=${new_value:-$value_default}

	value_default="self_signed"
	read -r -p "Email address to use for Lets Encrypt.
	Use 'self_signed' as your email to create self signed certificates.
	Use 'off' if you want to run the service without tls encryption. Make sure to use an ssl-terminating reverse proxy in front in this case.
	[$value_default]: " new_value
	EMAIL=${new_value:-$value_default}

	# Let Kapi accept self signed certs if required
	if [ "$EMAIL" == "self_signed" ]; then
		INSECURE="yes"
	else
		INSECURE="no"
	fi

	LDAP_BASE_DN=$(fqdn_to_dn "${FQDN%:*}")
	value_default="$LDAP_BASE_DN"
	read -r -p "Name of the BASE DN for LDAP [$value_default]: " new_value
	LDAP_BASE_DN=${new_value:-$value_default}

	value_default="ldap://ldap:389"
	read -r -p "LDAP server to be used (defaults to the bundled OpenLDAP) [$value_default]: " new_value
	LDAP_SERVER=${new_value:-$value_default}

	if [ "$LDAP_SERVER" != "$value_default" ]; then
		# We don't need an admin password in case we don't use the bundled LDAP server
		LDAP_ADMIN_PASSWORD=""

		value_default="$LDAP_BASE_DN"
		read -r -p "LDAP search base [$value_default]: " new_value
		LDAP_SEARCH_BASE=${new_value:-$value_default}

		value_default="cn=readonly,$LDAP_BASE_DN"
		read -r -p "LDAP bind user (needs read permissions) [$value_default]: " new_value
		LDAP_BIND_DN=${new_value:-$value_default}

		value_default="kopano123"
		read -r -p "LDAP bind password to be used [$value_default]: " new_value
		LDAP_BIND_PW=${new_value:-$value_default}

		PRINT_SETUP_SUCCESS="$PRINT_SETUP_SUCCESS \n!! You have specified the LDAP server '${LDAP_SERVER}', don't forget to remove the bundled ldap and ldap-admin services in docker-compose.yml\n"
	else
		value_default="yes"
		read -r -p "Use bundled LDAP with demo users? yes/no [$value_default]: " new_value
		LDAP_CONTAINER_QUESTION=${new_value:-$value_default}

		if [ "${LDAP_CONTAINER_QUESTION}" == "yes" ]; then
			LDAP_CONTAINER="kopano_ldap_demo"
		else
			LDAP_CONTAINER="kopano_ldap"
		fi

		LDAP_ADMIN_PASSWORD=$(random_string)
		LDAP_SEARCH_BASE="$LDAP_BASE_DN"
		LDAP_BIND_DN="cn=readonly,$LDAP_BASE_DN"
		LDAP_BIND_PW=$(random_string)
	fi

	if [ -f /etc/timezone ]; then
		value_default=$(cat /etc/timezone)
	elif [ -f /etc/localtime ]; then
		value_default=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
	else
		value_default="Europe/Berlin"
	fi

	read -r -p "Timezone to be used [$value_default]: " new_value
	TZ=${new_value:-$value_default}

	echo "${PRINT_SETUP_SUCCESS}"

	cat <<EOF > "./.env"
# please consult https://github.com/zokradonh/kopano-docker
# for possible configuration values and their impact

LDAP_CONTAINER=$LDAP_CONTAINER
LDAP_ORGANISATION="$LDAP_ORGANISATION"
LDAP_DOMAIN=${FQDN%:*}
LDAP_BASE_DN=$LDAP_BASE_DN
LDAP_SERVER=$LDAP_SERVER
LDAP_ADMIN_PASSWORD=$LDAP_ADMIN_PASSWORD
LDAP_READONLY_USER_PASSWORD=$LDAP_BIND_PW
LDAP_BIND_DN=$LDAP_BIND_DN
LDAP_BIND_PW=$LDAP_BIND_PW
LDAP_SEARCH_BASE=$LDAP_SEARCH_BASE

TZ=$TZ

# Defines how Kopano can be accessed from the outside world
FQDN=$FQDN
FQDNCLEANED=${FQDN%:*}
DEFAULTREDIRECT=/webapp
EMAIL=$EMAIL
CADDY=2015
HTTP=80
HTTPS=443

# Settings for test environments
INSECURE=$INSECURE

# Docker and docker-compose settings
# Docker Repository to push to/pull from
docker_repo=zokradonh
COMPOSE_PROJECT_NAME=kopano

# Additional packages to install
ADDITIONAL_KOPANO_PACKAGES=python3-grapi.backend.ldap

EOF
else
	echo ".env already exists with initial configuration"
	echo "If you want to change the configuration, please edit .env directly"
	exit 1
fi
