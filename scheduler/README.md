# Kopano Scheduler image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_scheduler.svg)](https://microbadger.com/images/zokradonh/kopano_scheduler "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_scheduler.svg)](https://microbadger.com/images/zokradonh/kopano_scheduler "Microbadger version")

Service to carry out repeating tasks within the Kopano environment. Takes care of initial user sync on startup and creating the public store.

## Recurring tasks and maintenance tasks within Kopano

There are certain tasks within Kopano that either need to be executed once (like creating the public store when starting a new environment for the first time) or on a regular base (like syncing the internal user list with and external ldap tree). For convinience this project includes a "scheduler" container that will take care of this and that can be dynamically configured through env variables.

The container knows two kinds of cron jobs (the crontab syntax is used for actual jobs):

- `CRON_ZPUSHGAB=0 22 * * * docker exec kopano_zpush z-push-gabsync -a sync`
  - Jobs prefixed with `CRON_` are executed once at container startup (and container startup will fail if one of the jobs fail) and then at the scheduled time.
- `CRONDELAYED_KBACKUP=30 1 * * * docker run --rm -it zokradonh/kopano_utils kopano-backup -h`
  - Jobs prefixed with `CRONDELAYED_` are only executed at the scheduled time.

Instead of using the internal scheduler one can also just use an existing scheduler (cron on the docker host for example) to execute these tasks.