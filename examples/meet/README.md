# Running Kopano Meet without Kopano (with only the LDAP backend)

The docker-compose.yml file in this directory can be used as a template to run Kopano Meet against a LDAP user directory. The file as it is starts a demo deployment of Meet including some pre created users to explore Kopano Meet.

Check https://github.com/zokradonh/kopano-docker/blob/master/ldap_demo/README.md to learn more about the included demo users.

## Instructions

1. run `setup.sh`
2. check `.env` for any required customization (port 443 already in use?)
3. run `docker-compose up` to start
4. navigate to https://your-domain to login to Kopano Meet
