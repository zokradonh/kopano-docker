# Situation and motivation:

* running the kopano stack behind an ssl-terminating proxy
* as less as possible maintenance effort --> run the kopano stack as close as possible at the default configuration
* using the kopano-stack to provide a central ldap authentication for the domain, but running the frontend using a subdomain

## Way to go:

1. initial clean **setup of kopano stack** --> follow the documentation of https://github.com/zokradonh/kopano-docker/blob/master/README.md
    1. clone the repo https://github.com/zokradonh/kopano-docker
    2. run the setup.sh (only steps, necessary for the configuration is shown here)
       1. Name of the Organisation for LDAP `mydomain.com`
       2. FQDN to be used (for reverse proxy) `kopano.mydomain.com`
       3. Email address to use for Lets Encrypt. `self_signed`
       4. Name of the BASE DN for LDAP `dc=mydomain,dc=com`
       5. E-Mail Address displayed for the 'postmaster' `postmaster@mydomain.com`

2. ensure ldap and reverse-proxy domain is split correctly in generated `.env` file:

```bash
LDAP_DOMAIN=mydomain.com
LDAP_BASE_DN=dc=mydomain,dc=com

FQDN=kopano.mydomain.com
```

3. ensure kwmserver is able to connect through an endpoint with valid ssl-certificate

```bash
FQDNCLEANED=somethingInvalidToEnforceConnectionFromOutsideEndpoint
```

4. ensure your traefik instance outside of the kopano-stack does allow **proxying to self-signed certificates**:

```bash
command: --insecureSkipVerify=true
```

5. disable the docker-host portmapping of the kopano-caddy proxy in `docker-compose.yml` to not interference with your traefik proxy

```yaml
services:
  web:
...
#    ports:
#      - "${CADDY:-2015}:2015"
#      - "${HTTP:-80}:80"
#      - "${HTTPS:-443}:443"
```

6. make the self-signed kopano reverse-proxy available in traefik via `docker-compose.override.yml`

```yaml
version: "3.5"

services:
  web:
    networks:
      proxy-net:
    labels:
      traefik.enable: true 
      traefik.frontend.rule: "Host:${FQDN}"
      traefik.port: 2015
      traefik.protocol: https
      traefik.docker.network: "proxy-net"
      traefik.frontend.headers.forceSTSHeader: true
      traefik.frontend.headers.STSSeconds: 315360000
      traefik.frontend.headers.STSIncludeSubdomains: true
      traefik.frontend.headers.STSPreload: true

networks:
  proxy-net:
    external: true
  ldap-net:
    name: ldap-net
```

Everything else should be configurable as normal. My test-setup showed a functional active-sync connection using the mdm plugin in the webapp, as well as screensharing via kopano-meet.
