# KopanoDocker
Unofficial kopano docker images for all kopano services.
Use kopano_core image for server/spooler/dagent/search/monitor/ical/gateway services.
Use kopano_webapp for web service.

Example
=======

docker-compose.yml
```
version: '3'

services:

  kserver:
    image: zokradonh/kopano_core:${CORE_VERSION}
    hostname: kserver
    container_name: kopano_server
    links:
      - db
    depends_on:
      - "kssl"
    environment:
      - TZ=Europe/Berlin
      - KCCONF_SERVER_COREDUMP_ENABLED=no
      - KCCONF_SERVER_LOG_LEVEL=4
      - KCCONF_SERVER_MYSQL_HOST=db
      - KCCONF_SERVER_MYSQL_PORT=3306
      - KCCONF_SERVER_MYSQL_DATABASE=kopano
      - KCCONF_SERVER_MYSQL_USERNAME=root
      - KCCONF_SERVER_MYSQL_PASSWORD=YOUR_MYSQL_ROOT_PASSWORD  #change here
      - KCCONF_SERVER_SERVER_SSL_KEY_FILE=/kopano/ssl/kserver.pem
      - KCCONF_SERVER_SERVER_SSL_CA_FILE=/kopano/ssl/ca.pem
      - KCCONF_SERVER_SSLKEYS_PATH=/kopano/ssl/clients
      - KCCONF_SERVER_PROXY_HEADER=* # delete line if webapp is not behind reverse proxy
      - KCCONF_SERVER_SYSTEM_EMAIL_ADDRESS=hostmaster@domain.tld  #change here
      - KCCONF_SERVER_DISABLED_FEATURES=pop3
      - KCCONF_SERVER_SEARCH_SOCKET=http://ksearch:238/
      - KCCONF_LDAP_LDAP_URI=ldaps://ldapserver:ldapport  #change here
      - KCCONF_LDAP_LDAP_BIND_USER=cn=SOME_STANDARD_USER,OU=MyUsers,DC=domain,DC=tld #change here
      - KCCONF_LDAP_LDAP_BIND_PASSWD=PASSWORD_OF_STANDARD_USER  #change here
      - KCCONF_LDAP_LDAP_SEARCH_BASE=OU=MyUsers,dc=domain,dc=tld  #change here
      - KCCOMMENT_LDAP_1=!include /usr/share/kopano/ldap.openldap.cfg #delete if you want openldap
      - KCUNCOMMENT_LDAP_1=!include /usr/share/kopano/ldap.active-directory.cfg #delete if you want openldap
    networks:
      - kopanonet
    volumes:
      - data:/kopano/data
      - sslcerts:/kopano/ssl

  kdagent:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_dagent
    links:
      - kserver
    volumes:
      - sslcerts:/kopano/ssl
    environment:
      - TZ=Europe/Berlin
      - KCCONF_DAGENT_LOG_LEVEL=6
      - KCCONF_DAGENT_SERVER_SOCKET=https://kserver:237/
      - KCCONF_DAGENT_SSLKEY_FILE=/kopano/ssl/kdagent.pem
    networks:
      - kopanonet

  kgateway:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_gateway
    links:
      - kserver
    volumes:
      - ./gatewaycerts/:/kopano/certs/
    environment:
      - TZ=Europe/Berlin
      - KCCONF_GATEWAY_SERVER_SOCKET=http://kserver:236/
      - KCCONF_GATEWAY_SSL_PRIVATE_KEY_FILE=/kopano/certs/yourcert.key # change here
      - KCCONF_GATEWAY_SSL_CERTIFICATE_FILE=/kopano/certs/yourcert.pem # change here
    networks:
      - kopanonet

  kical:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_ical
    links:
      - kserver
    environment:
      - TZ=Europe/Berlin
      - KCCONF_ICAL_SERVER_SOCKET=http://kserver:236/
    networks:
      - kopanonet

  kmonitor:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_monitor
    links:
      - kserver
    volumes:
      - sslcerts:/kopano/ssl
    environment:
      - TZ=Europe/Berlin
      - KCCONF_MONITOR_SERVER_SOCKET=https://kserver:237/
      - KCCONF_MONITOR_SSLKEY_FILE=/kopano/ssl/kmonitor.pem
    networks:
      - kopanonet

  ksearch:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_search
    links:
      - kserver
    volumes:
      - sslcerts:/kopano/ssl
    environment:
      - TZ=Europe/Berlin
      - KCCONF_SEARCH_SERVER_BIND_NAME=http://ksearch:238
      - KCCONF_SEARCH_SERVER_SOCKET=https://kserver:237/
      - KCCONF_SEARCH_SSLKEY_FILE=/kopano/ssl/ksearch.pem
    networks:
      - kopanonet

  kspooler:
    image: zokradonh/kopano_core:${CORE_VERSION}
    container_name: kopano_spooler
    links:
      - kserver
    volumes:
      - sslcerts:/kopano/ssl
    environment:
      - TZ=Europe/Berlin
      - KCCONF_SPOOLER_SERVER_SOCKET=https://kserver:237/
      - KCCONF_SPOOLER_LOG_LEVEL=4
      - KCCONF_SPOOLER_SMTP_SERVER=kmta
      - KCCONF_SPOOLER_SSLKEY_FILE=/kopano/ssl/kspooler.pem
    networks:
      - kopanonet

  kwebapp:
    image: zokradonh/kopano_webapp:${WEBAPP_VERSION}
    hostname: kwebapp
    container_name: kopano_webapp
    links:
      - kserver
    #ports:
    #  - "8236:80"
    #  - "8237:443"
    volumes:
      - syncstates:/var/lib/z-push/
      - sslcerts:/kopano/ssl
    environment:
      - TZ=Europe/Berlin
      - KCCONF_SERVERHOSTNAME=kserver
      - KCCONF_SERVERPORT=237
    networks:
      - web
      - kopanonet

  kssl:
    image: zokradonh/kopano_ssl
    container_name: kopano_ssl
    volumes:
      - sslcerts:/kopano/ssl

  kmta:
    image: tvial/docker-mailserver:latest
    hostname: myhost #change here
    domainname: domain.tld #change here
    #dns: 127.0.0.1
    container_name: kopano_mta
    #links:
    #  - adtunnel
    ports:
      - "25:25"
    #  - "143:143"
    #  - "587:587"
    #  - "993:993"
    volumes:
      - tmpmaildata:/var/mail
      - tmpmailstate:/var/mail-state
      - ./mtaconfig/:/tmp/docker-mailserver/ # create this dir
    environment:
      - TZ=Europe/Berlin
      - ENABLE_SPAMASSASSIN=1
      - ENABLE_CLAMAV=1
      - ENABLE_FAIL2BAN=1
      - ENABLE_POSTGREY=1
      - TLS_LEVEL=intermediate
      - POSTGREY_DELAY=10
      - ONE_DIR=1
      - DMS_DEBUG=0
      - ENABLE_LDAP=1
      - LDAP_SERVER_HOST=ldaps://ldapserver:ldapport #change here
      - LDAP_SEARCH_BASE=OU=MyUsers,DC=domain,DC=tld #change here
      - LDAP_BIND_DN=cn=SOME_STANDARD_USER,OU=MyUsers,DC=domain,DC=tld #change here
      - LDAP_BIND_PW=PASSWORD_OF_SOME_STANDARD_USER #change here
      - LDAP_QUERY_FILTER_USER=(&(objectClass=user)(|(mail=%s)(otherMailbox=%s)))
      - LDAP_QUERY_FILTER_GROUP=(&(objectclass=group)(mail=%s))
      - LDAP_QUERY_FILTER_ALIAS=(&(objectClass=user)(otherMailbox=%s))
      - LDAP_QUERY_FILTER_DOMAIN=(&(|(mail=*@%s)(otherMailbox=*@%s)(mailGroupMember=*@%s))(kopanoAccount=1)(|(objectClass=user)(objectclass=group)))
      - ENABLE_SASLAUTHD=1
      - SASLAUTHD_LDAP_SERVER=ldaps://ldapserver:ldapport #change here
      - SASLAUTHD_LDAP_BIND_DN=cn=SOME_STANDARD_USER,OU=MyUsers,DC=domain,DC=tld #change here
      - SASLAUTHD_LDAP_PASSWORD=PASSWORD_OF_SOME_STANDARD_USER  #change here
      - SASLAUTHD_LDAP_SEARCH_BASE=OU=MyUsers,DC=domain,DC=tld  #change here
      - SASLAUTHD_LDAP_FILTER=(&(sAMAccountName=%U)(objectClass=person))
      - SASLAUTHD_MECHANISMS=ldap
      - POSTMASTER_ADDRESS=postmaster@domain.tld #change here
      - SMTP_ONLY=1
      - PERMIT_DOCKER=network
      - ENABLE_POSTFIX_VIRTUAL_TRANSPORT=1
      - POSTFIX_DAGENT=lmtp:kdagent:2003
      - REPORT_RECIPIENT=1
    networks:
      - kopanonet
    cap_add:
      - NET_ADMIN
      - SYS_PTRACE

  db:
    image: mariadb
    restart: always
    container_name: kopano_db
    volumes:
      - db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=YOUR_MYSQL_ROOT_PASSWORD  #change here
      - MYSQL_PASSWORD=YOUR_PASSWORD #change here
      - MYSQL_DATABASE=kopano
      - MYSQL_USER=kopano
    networks:
      - kopanonet

volumes:
  db:
  data:
  syncstates:
  sslcerts:
  tmpmaildata:
  tmpmailstate:

networks:
  web: # this requires an external docker container that is a http reverse proxy (e.g. haproxy)
    external:
      name: haproxy_webrproxynet
  kopanonet:
    driver: bridge
```

Requires haproxy network for http reverse proxy.
Change all lines which are commented especially those with #change here

This is just a quick example docker-compose.yml made in some minutes to provide a better start.

Requires `.env` file next to docker-compose.yml with content like this
```
CORE_VERSION=8.6.80.1055-0plus156.1
WEBAPP_VERSION=3.4.17.1565plus895.1
```

Requires `ldap-groups.cf` in ./mtaconfig directory next to docker-compose.yml
```
bind                     = yes
bind_dn                  = cn=admin,dc=domain,dc=com
bind_pw                  = admin
query_filter             = (&(mailGroupMember=%s)(mailEnabled=TRUE))
result_attribute         = mail
search_base              = ou=people,dc=domain,dc=com
server_host              = mail.domain.com
start_tls                = no
version                  = 3
leaf_result_attribute = mail
special_result_attribute = member
```
Now group members of Active Directory groups can be found by postfix.

Furthermore you can use this directory for opendkim - see kmta's image for details.
