# Running Kopano Meet without Kopano (with only the LDAP backend)

The docker-compose.yml file in this directory can be used as a template to run Kopano Meet against a LDAP user directory. The file as it is starts a demo deployment of Meet including some pre created users to explore Kopano Meet.

Check https://github.com/zokradonh/kopano-docker/blob/master/ldap_demo/README.md to learn more about the included demo users.

## Instructions

1. run `setup.sh`
2. check `.env` for any required customization (port 443 already in use?)
3. run `docker-compose up` to start
4. navigate to https://your-domain to login to Kopano Meet

## Additional environment variables for using ActiveDirectory

Create the a file named `docker-compose.override.yml` with the following content in case you are using Microsoft ActiveDirectory.

```yaml
version: "3.5"

services:

  kopano_grapi:
    environment:
      - LDAP_FILTER=(&(objectClass=organizationalPerson)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))
      - LDAP_LOGIN_ATTRIBUTE=sAMAccountName
      - LDAP_EMAIL_ATTRIBUTE=mail
      - LDAP_NAME_ATTRIBUTE=displayName
      - LDAP_FAMILY_NAME_ATTRIBUTE=sn
      - LDAP_GIVEN_NAME_ATTRIBUTE=givenName
      - LDAP_JOB_TITLE_ATTRIBUTE=title
      - LDAP_OFFICE_LOCATION_ATTRIBUTE=L
      - LDAP_BUSINESS_PHONE_ATTRIBUTE=telephoneNumber
      - LDAP_MOBILE_PHONE_ATTRIBUTE=mobile
      - USERID_SEARCH_FILTER_TEMPLATE=({loginAttribute}=%(userid)s)
      - SEARCH_SEARCH_FILTER_TEMPLATE=(&(objectClass=organizationalPerson)(!(UserAccountControl:1.2.840.113556.1.4.803:=2))(|({emailAttribute}=*%(search)s*)({givenNameAttribute}=*%(search)s*)({familyNameAttribute}=*%(search)s*)))


kopano_konnect:
    environment:
      - LDAP_LOGIN_ATTRIBUTE=sAMAccountName
      - LDAP_NAME_ATTRIBUTE=displayName
      - LDAP_UUID_ATTRIBUTE_TYPE=binary
      - LDAP_UUID_ATTRIBUTE=objectGUID
```
