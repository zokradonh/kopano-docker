# Running kopano-docker together with Owncloud

To have a demo environment that runs both Kopano and Owncloud perform the following modifications:

1. Add the `owncloud.yml` to the `COMPOSE_FILE` variable in your `.env` file.

Example:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:owncloud/owncloud.yml
```

2. run `owncloud.sh` to create the required runtime variables in your `.env` file.

3. run `docker-compose up -d` and you will be able to log into `https://your-fqdn/owncloud`.