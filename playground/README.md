# Kopano Playground image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_playground.svg)](https://microbadger.com/images/zokradonh/kopano_playground "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_playground.svg)](https://microbadger.com/images/zokradonh/kopano_playground "Microbadger version")

Example applications to test Konnect and Kapi.

## What are and how can I use the Kapi Playground and OIDC Playground?

This project includes a Docker container to easily inspect the data returned by the Kopano Rest API (KAPI), as well as the OpenID (Connect) Service Provider. To explore these applications you need to pass the URL of the "Issuer" when opening these. For the Kapi Playground this would for example be `https://kopano.demo/kapi-playground/?iss=https://kopano.demo`. For the OIDC Playground it would be `https://kopano.demo/oidc-playground/?discovery_uri=https://kopano.demo/.well-known/openid-configuration&discovery=auto`.