# Kopano Kapi Playground and OIDC Playground image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_playground.svg)](https://microbadger.com/images/zokradonh/kopano_playground "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_playground.svg)](https://microbadger.com/images/zokradonh/kopano_playground "Microbadger version")

This project includes a Docker container to easily inspect the data returned by the Kopano Rest API (Kapi), as well as the OpenID (Connect) Service Provider.

## How to use the Kopano Playground?

1. Add the `playground.yml` to the `COMPOSE_FILE` variable in your `.env` file.

Example:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:playground/playground.yml
```

2. Run `docker-compose up -d`.

To explore these applications you need to pass the URL of the "Issuer" when opening these. For the Kapi Playground this would for example be `https://kopano.demo/kapi-playground/?iss=https://kopano.demo`. For the OIDC Playground it would be `https://kopano.demo/oidc-playground/?discovery_uri=https://kopano.demo/.well-known/openid-configuration&discovery=auto`.
