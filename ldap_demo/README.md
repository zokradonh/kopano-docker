# Kopano LDAP demo image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_ldap_demo.svg)](https://microbadger.com/images/zokradonh/kopano_ldap_demo "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_ldap_demo.svg)](https://microbadger.com/images/zokradonh/kopano_ldap_demo "Microbadger version")

Image to for an OpenLDAP server to provide some demo users for Kopano. Based on https://github.com/osixia/docker-openldap.

The LDAP tree is prepared for both single tenant setups (the default in Kopano) and multi tenant setups. To configure the multi tenant mode (also referred to as "hosted") of `kopano-server` the following values need to be added to `kopano_server.env`:

```bash
KCCONF_SERVER_ENABLE_HOSTED_KOPANO=YES
KCCONF_LDAP_LDAP_COMPANY_TYPE_ATTRIBUTE_VALUE=kopano-company
```

Additionally the ldap tree is also prepared for multiserver installations (also referred to as "distributed"), where multiple `kopano-server` processes share the total amount of mailboxes (controlled through a manual mapping in LDAP). See [Multiserver Example](../examples/kopano-multiserver) for more information.

```bash
$ docker-compose -f examples/kopano-multiserver.yml up
```

Demo users created in the demo ldap all have a password that is identical to the username, e.g. the password for `user1` user `user1`. The user `user23 is setup to be an admin within Kopano.`
