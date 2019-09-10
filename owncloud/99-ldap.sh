#!/usr/bin/env bash

echo "Configuring LDAP for kopano-docker"

set -x

occ app:enable user_ldap
occ ldap:show-config

if [[ "$(occ ldap:show-config)" == "" ]]; then
	su -c "php occ ldap:create-empty-config" www-data
fi

ldapHost=${LDAP_SERVER%:*}
ldapPort=${LDAP_SERVER##*:}

occ ldap:set-config s01 ldapHost ${ldapHost}
occ ldap:set-config s01 ldapPort ${ldapPort}
occ ldap:set-config s01 ldapAgentName ${LDAP_BIND_DN}
occ ldap:set-config s01 ldapAgentPassword ${LDAP_BIND_PW}
occ ldap:set-config s01 ldapBase ${LDAP_SEARCH_BASE}
occ ldap:set-config s01 ldapUserFilter "(|(objectclass=kopano-user))"
occ ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=kopano-user))(uid=%uid))"
occ ldap:set-config s01 ldapGroupFilter "(&(|(objectclass=kopano-group)))"
occ ldap:set-config s01 ldapConfigurationActive 1

/usr/bin/occ user:sync -m disable "OCA\User_LDAP\User_Proxy"

cat << EOF >| /etc/cron.d/sync
*/10  *  *  *  * root /usr/bin/occ user:sync -m disable 'OCA\User_LDAP\User_Proxy'
EOF

true
