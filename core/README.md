# Kopano Core image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_core.svg)](https://microbadger.com/images/zokradonh/kopano_core "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_core.svg)](https://microbadger.com/images/zokradonh/kopano_core "Microbadger version")

Image for components out of the "Kopano Core" repository. Is used to start containers for e.g. `kopano-server` and `kopano-gateway`.

E-Mail attachment directory is by default in `/kopano/data/attachments/` it is recommended to bind `/kopano/data` as volume.

Attachment location can be configured by setting the environment variable `KCCONF_SERVER_ATTACHMENT_PATH`.

All configuration can be adjusted dynamically through environment variables. 

```
KCCONF_SERVER_MYSQL_HOST=127.0.0.1
^      ^     ^   ^
|      |     |   |
General prefix   |
       |     |   |
        Name of the relevant configuration file (server.cfg in this case)
             |   |
             Name of the configuration option in the configuration file
                 |
                 Value of the configuration option
```

Examples:
- specify `KCCONF_SERVER_MYSQL_HOST` for `mysql_host` setting in `server.cfg`
- specify `KCCONF_LDAP_LDAP_SEARCH_BASE` to set `ldap_search_base` in `ldap.cfg`

Additionally it is possible to comment specific options in/out with `KCCOMMENT_filenameWithoutExtension_anystring=searchline`  
e.g. `KCCOMMENT_LDAP_1=!include /usr/share/kopano/ldap.openldap.cfg`

For coredumps on crashes kopano-server requires the fs.suid_dumpable sysctl to contain the value 2, not 0.

It is recommended to sync the user list before the first login of a user. With the bundled ´docker-compose.yml´ the ´kopano_scheduler´ container will take care of this. Alternatively `kopano-cli --list-users` could be run once after initial install in the kopano_server container.

Example:

`docker-compose exec kserver kopano-cli --list-users`

Depending on the overall performance of the system and the amount of user the first execution of this command will take a moment before it produces any output. This is since this command kicks off the mailbox creation for the users.

See https://documentation.kopano.io/kopanocore_administrator_manual/configure_kc_components.html#testing-ldap-configuration for more information.

## Ports & Proxying

- kopano-server is configured to listen on the ports 236 (plain) and 237 (https)
- kopano-ical is configured to listen on the port 8080, but the web container is also configured to proxy access to http(s)://FQDN/caldav to kopano-ical
- kopano-gateway is configured to listen on IMAP traffic on port 143. Pop3 is deactivated by default but whould be listening on port 110. Pop3s and IMAPs are currently not configured. (see https://github.com/zokradonh/kopano-docker/issues/16 for more details).

# Reminder for reload debugging

docker top kopano_server
docker-compose kill -s SIGHUP kopano_serve