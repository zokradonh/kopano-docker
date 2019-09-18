# LDAP extras for kopano-docker

This directory contains a compose file including optional containers.

## How to use this compose file?

 1. Add the `ldap-extras.yml` to the `COMPOSE_FILE` variable in your `.env` file.

 Example:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:ldap-extras/ldap-extras.yml
```

 2. Run `docker-compose up -d`.

 ## ldap-admin

After startup you can access phpLDAPadmin by going to `https://kopano.demo/ldap-admin`

To login use the `cn=admin,$LDAP_BASE_DN` and `LDAP_BIND_PW` from the `.env` file.

Check https://documentation.kopano.io/kopanocore_administrator_manual/user_management.html#user-management-from-openldap to learn more about Kopanos LDAP possibilities.

## password-self-service

After startup you can access [Self Service Password](https://ltb-project.org/documentation/self-service-password) by visiting `https://kopano.demo/password-reset/`.
