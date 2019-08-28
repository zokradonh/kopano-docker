# Configuration example for running Kopano in a Multiserver setup

**Hint:** The configuration as it is requires that you clean out existing Kopano containers and data volumes, as the additional database is only created on the initial start of the database container.

1. Add the `kopano-multiserver.yml` to the `COMPOSE_FILE` variable in your `.env` file.

 Example:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:examples/kopano-multiserver/kopano-multiserver.yml
```

2. run `docker-compose up -d` from the root of this project.