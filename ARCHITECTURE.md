# Architecture Overview

Aka "How do the containers connect/relate/interact with each other?"

## web

- external entry point for users accessing Kopano
  - reverse proxy for containers exposing a web interface
- can retrieve ssl certificate from Let's Encrypt
- redirects all requests to /webapp by default
- recommended to use as it makes web configuration easy and secure (manual configuration will be tedious and potentially less secure)

## ldap

- (optional) bundles OpenLDAP service
- kopano_server is using LDAP to manage users

## ldap-admin and password-self-service

- optional containers to manage users in ldap and let users change their password

## mail

- MTA stack with anti-spam and anti-virus
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

- provides Pop3 and IMAP access for users

## kopano_ical

- provides iCAL and CalDAV access for users (will be replaced with KDav in the future)

## kopano_monitor

- monitors mailbox usage and sends quota mails (by directly delivering a mail into the users inbox)

## kopano_search

- provides full text indexing for mailboxes

## kopano_konnect

- authentication component (OpenID Connect)
- required for apps interacting with the Kopano RestAPI (e.g. Kopano Meet)

## kopano_kwmserver

- WebRTC signalling server

## kopano_meet

- provides the Meet web application/frontend

## kopano_scheduler

- helper container to execute scheduled tasks within Kopano
