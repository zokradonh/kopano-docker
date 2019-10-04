# Architecture Overview

## web

- external entry point for users accessing Kopano Meet
    - reverse proxy for kopano_kapi, kopano_konnect, kopano_kwmserver and kopano_meet 
- can retrieve ssl certificate from Lets Encrypt
- redirects all requests to /meet
- recommended to use as it makes web configuration easy and secure (manual configuration will be tendious and potentially less secure)

## ldap

- (optional) bundles OpenLDAP service
- Konnect and Grapi are using it

## kopano_ssl

- helper container to generate ssl certificates for internal usage
- will create required files and then stop

## kopano_grapi

- groupware backend of the Kopano RestAPI
- connects to LDAP to provide a global addressbook to users

## kopano_kapi

- http endpoint of the Kopano RestAPI
- stores recent calls for the user in a key value stores (queried over Rest)

## kopano_konnect

- authentification component (OpenID Connect) for Meet
- connects to the LDAP backend to verify user logins via bind

## kopano_kwmserver

- WebRTC signalling server

## kopano_meet

- provides the Meet web application/frontend