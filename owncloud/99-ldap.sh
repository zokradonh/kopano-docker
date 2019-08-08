#!/usr/bin/env bash

echo "Configuring LDAP for kopano-docker"

occ app:enable user_ldap
occ ldap:show-config

if [[ "$(occ ldap:show-config)" == "" ]]; then
    su -c "php occ ldap:create-empty-config" www-data
fi

occ ldap:set-config s01 ldapHost ${LDAP_SERVER}
occ ldap:set-config s01 ldapAgentName ${LDAP_BIND_DN}
occ ldap:set-config s01 ldapAgentPassword ${LDAP_BIND_PW}
occ ldap:set-config s01 ldapBase ${LDAP_SEARCH_BASE}
occ ldap:set-config s01 ldapUserFilter ${LDAP_QUERY_FILTER_USER}
occ ldap:set-config s01 ldapGroupFilter ${LDAP_QUERY_FILTER_GROUP}
occ ldap:set-config s01 ldapConfigurationActive 1

/usr/bin/occ user:sync -m disable "OCA\User_LDAP\User_Proxy" 

cat << EOF >| /etc/cron.d/sync
*/10  *  *  *  * root /usr/bin/occ user:sync -m disable 'OCA\User_LDAP\User_Proxy'
EOF


true
