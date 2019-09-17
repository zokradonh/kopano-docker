# How the containers connect to each other

## web

- external entry point for users accessing Kopano Meet
    - reverse proxy for containers exposing a web interface 
- can retrieve ssl certificate from Lets Encrypt
- redirects all requests to /webapp

## ldap

- (optional) bundles OpenLDAP service
- kopano_server is using LDAP to manage users

## ldap-admin and password-self-service

- optional containers to manage users in ldap and let users change their password
- will in the future be moved into their own file https://github.com/zokradonh/kopano-docker/issues/244

## mail

- mta stack with anti spam and anti virus
- connects against the ldap to verify users

## db

- (optional) bundles MariaDB for the Kopano database

## kopano_ssl

- helper container to generate ssl certificates for internal usage
- will create required files and then stop

## kopano_server

- main process of the Kopano deployment
- connects towards LDAP to get a list of users and verify user logins via bind

## kopano_webapp

- provides Kopano WebApp, so users can interact with their mailboxes via their browser

## kopano_zpush

- provides Z-Push, so users can sync their mailboxes to phones and tablets

## kopano_grapi

- groupware backend of the Kopano RestAPI

## kopano_kapi

- http endpoint of the Kopano RestAPI
- stores recent calls for the user in a key value stores (queried over Rest)

## kopano_kdav

- provides KDav, so users can sync their calendars and contacts via CalDAV and CardDAV

## kopano_dagent

- mail delivery part for kopano_server
- mta delivers mail to it, dagent delivers the mail into the desired inbox

## kopano_spooler

- mail sending part for kopano_server
- monitors outboxes of users, submits mails to the mta

## kopano_gateway

- provides Pop3 and Imap access for users

## kopano_ical

- provides ical and CalDAV access for users (will be replaced with kdav in the future)

## kopano_monitor

- monitors mailbox usage and sends quota mails

## kopano_search

- provides full text indexing for mailboxes

## kopano_konnect

- authentification component (OpenID Connect) for Meet

## kopano_playground

- web interface to explore OpenID flows and the Kopano RestAPI
- will move into a dedicated file in the future https://github.com/zokradonh/kopano-docker/issues/245

## kopano_kwmserver

- WebRTC signalling server

## kopano_meet

- provides the Meet web application/frontend

## kopano_scheduler

- helper container to execute scheduled tasks within Kopano