# Kopano LDAP demo image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_ldap_demo.svg)](https://microbadger.com/images/zokradonh/kopano_ldap_demo "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_ldap_demo.svg)](https://microbadger.com/images/zokradonh/kopano_ldap_demo "Microbadger version")

Image to for an OpenLDAP server to provide some demo users for Kopano. Based on https://github.com/osixia/docker-openldap.

The LDAP tree is prepared for both single tenant setups (the default in Kopano) and multi tenant setups. To configure the multi tenant mode (also referred to as "hosted") in `kopano-server` the following values need to be added to `kopano_server.env`:

```
KCCONF_SERVER_ENABLE_HOSTED_KOPANO=YES
KCCONF_LDAP_LDAP_COMPANY_TYPE_ATTRIBUTE_VALUE=kopano-company
```