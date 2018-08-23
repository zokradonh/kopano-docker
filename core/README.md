E-Mail attachment directory is by default in `/kopano/data/attachments/` so bind `/kopano/data` as volume.

You can reconfigure by setting environment variable `KCCONF_SERVER_ATTACHMENT_PATH`.

You can change all server.cfg settings you like prefixed with `KCCONF_SERVER_`
So specify `KCCONF_SERVER_MYSQL_HOST` for `mysql_host` setting in `server.cfg`.
Or specify `KCCONF_LDAP_LDAP_SEARCH_BASE` to set `ldap_search_base` in `ldap.cfg`.

You may override default settings with `KCCONF_*` options or comment specific options in/out with `KCCOMMENT_filenameWithoutExtension_anystring=searchline`  
e.g. `KCCOMMENT_LDAP_1=!include /usr/share/kopano/ldap.openldap.cfg`

For coredumps on crashes kopano-server requires the fs.suid_dumpable sysctl to contain the value 2, not 0.

The docker image kopano_ssl will create certificates for all containers. Those certificates are selfsigned and only for internal Kopano component communication.

kopano_webapp port 80 is meant to be published through a https reverse proxy. MAPI connection for Outlook is also handled over port 80.

Maybe you need to execute `kopano-cli --list-users` once after initial install in the kopano_server container.

See: https://documentation.kopano.io/kopanocore_administrator_manual/configure_kc_components.html#testing-ldap-configuration

Example:

`docker-compose exec kserver kopano-cli --list-users` (This may last very long without any console output.)


Building supported Kopano
=====
If you have an active Kopano subscription you need specify the following build time arguments:
- KOPANO_CORE_REPOSITORY_URL to `https://serial:<YOURSERIAL>@download.kopano.io/supported/core:/final/Debian_9.0`
- RELEASE_KEY_DOWNLOAD to 1
- DOWNLOAD_COMMUNITY_PACKAGES to 0

Example:

`docker build --build-arg KOPANO_CORE_REPOSITORY_URL=https://serial:ABC123456789@download.kopano.io/supported/core:/final/Debian_9.0 --build-arg RELEASE_KEY_DOWNLOAD=1 --build-arg DOWNLOAD_COMMUNITY_PACKAGES=0 https://github.com/zokradonh/kopano-docker.git#:core`