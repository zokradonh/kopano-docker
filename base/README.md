E-Mail attachment directory is by default in `/kopano/data/attachments/` so bind `/kopano/data` as volume.

You can reconfigure by setting environment variable `KCCONF_SERVER_ATTACHMENT_PATH`.

You can change all server.cfg settings you like prefixed with "`KCCONF_SERVER_`"
So specify "`KCCONF_SERVER_MYSQL_HOST`" for "mysql\_host" setting in "server.cfg".
Or specify "`KCCONF_LDAP_LDAP_SEARCH_BASE`" to set "ldap\_search_base" in "ldap.cfg".

This image activates ActiveDirectory mode (Not OpenLDAP).
So you need an ActiveDirectory already running to use this.
You may try to override default settings with "`KCCONF_*`" options but using OpenLDAP instead of ActiveDirectory will fail due to !include command in ldap.cfg. This docker image does not support any method to edit this file. Create your own Dockerfile to enable OpenLDAP.

For coredumps on crashes kopano-server requires the fs.suid_dumpable sysctl to contain the value 2, not 0.

The docker image kopano_ssl will create certificates for all containers. Those certificates are selfsigned and only for internal Kopano component communication.

kopano_webapp port 80 is meant to be published through a https reverse proxy. MAPI connection for Outlook is also handled over port 80.

Maybe you need to execute `kopano-cli --list-users` once after initial install in the kopano_server container
see https://documentation.kopano.io/kopanocore_administrator_manual/configure_kc_components.html#testing-ldap-configuration

Example:
`docker-compose exec kserver kopano-cli --list-users` (This may last very long without any console output.)