# Kopano Web image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_web.svg)](https://microbadger.com/images/zokradonh/kopano_web "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_web.svg)](https://microbadger.com/images/zokradonh/kopano_web "Microbadger version")

Reverse Proxy to securely and with as less configuration effort as possible expose Kopano to the public internet.

In its default configuration this container will redirect requests to the root of the domain (so for example when opening https://kopano.demo/ in a browser) to https://kopano.demo/webapp. To redirect to a different path the environment variable `DEFAULTREDIRECT` needs to be configured.

Example:

```bash
# the following value needs to be added to .env
DEFAULTREDIRECT=/meet
```

## Serving additional files

Kweb in the Web container can easily be extended to serve static content. By default it will serve all content that has been copied into `/var/www/`. To extend the built in configuration file just add an additional file into `/etc/kweb-extras/`. Kweb is using the [Caddyfile syntax](https://caddyserver.com/v1/docs/caddyfile).

## Using existing ssl certificates

By default this container will use automatic tls certificates provided by Let's Encrypt. This can be influenced through the following environment variables:

```
# 1. Automatic HTTPS from letsencrypt
TLS_MODE=tls_auto
EMAIL=example@example.com

# 2. Custom certificate and key
# TLS_MODE=tls_custom
# TLS_CERT=/src/ssl/cert.pem
# TLS_KEY=/src/ssl/key.pem

# 3. Self signed certificate (FOR DEBUGGING)
# TLS_MODE=tls_selfsigned

# 4. Disable TLS entirely
# TLS_MODE=tls_off
```

## Information needed when not running your own reverse proxy

The `kopano_webapp` container is accessible on port 9080 and serves the WebApp on `/webapp`.
