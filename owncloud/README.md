# Running kopano-docker together with Owncloud

To have a demo environment that runs both Kopano and Owncloud perform the following modifications. This setup uses the official images from https://hub.docker.com/r/owncloud/server.

1. Add the `owncloud.yml` to the `COMPOSE_FILE` variable in your `.env` file.

Example:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:owncloud/owncloud.yml
```

2. run `owncloud.sh` to create the required runtime variables in your `.env` file.

3. run `docker-compose up -d` and you will be able to log into `https://your-fqdn/owncloud`.

## Further tweaks

Add the following to `kopano_webapp.env` to have the intranet plugin display both Kopano Meet as well as Owncloud (replace `kopano.demo with your own `fqdn):

```
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_USER_DEFAULT_ENABLE=true
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_BUTTON_TITLE=Kopano Meet
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_URL=https://kopano.demo/meet/
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_AUTOSTART=true
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_ICON=resources/icons/icon_default.png

KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_AUTOSTART_1=true
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_URL_1=https://kopano.demo/owncloud/
KCCONF_WEBAPPPLUGIN_INTRANET_PLUGIN_INTRANET_BUTTON_TITLE_1=Owncloud

```

Add/extend the following line in your `.env`:

```
ADDITIONAL_KOPANO_WEBAPP_PLUGINS="kopano-webapp-plugin-intranet kopano-webapp-plugin-files kopano-webapp-plugin-filesbackend-owncloud"
```
