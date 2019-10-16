# Configuration example for running Kopano in a Multiserver setup

This example shows how a Kopano Multiserver/Distributed setup can be achieved. The design is by no means perfect (a real deployment could make use of zero user/cachine nodes to handle front facing components), but its functional. Users will be able to login to Kopano WebApp as well as Meet and see users of other nodes and will be able to mail/call with them.

**Hint:** The configuration as it is requires that you clean out existing Kopano containers and data volumes, as the additional database is only created on the initial start of the database container.

1. Add the `kopano-multiserver.yml` to the `COMPOSE_FILE` variable in your `.env` file.

Example:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:examples/kopano-multiserver/kopano-multiserver.yml
```

2. run `docker-compose up -d` from the root of this project.