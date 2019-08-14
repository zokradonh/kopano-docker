# Kopano Grapi-Explorer

TODO what is grapi-explorer? what can it be used for?

 1. Add the `grapi-explorer.yml` to the `COMPOSE_FILE` variable in your `.env` file.

 Example:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:grapi-explorer/grapi-explorer.yml
```
 2. run `docker-compose up -d` and you will find the grapi-explorer at `https//your-fqdn:3000`.