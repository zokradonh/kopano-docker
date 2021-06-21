# kopano-spamd extras for kopano-docker

This directory contains a compose file including optional containers to enable learning spam to be used with the [SpamAssassin](https://spamassassin.apache.org/) bayes filter.

## How to use this compose file?

1. Add the `spamd-extras.yml` to the `COMPOSE_FILE` variable in your `.env` file.

Example:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:spamd-extras/spamd-extras.yml
```

2. Run `docker-compose up -d`.


## kopano-spamd

After startup there will be a new service `kopano-spamd` which will persist mails that are moved to `Junk` to a folder named `spam` inside the `kopanospamd` volume.
Likewise mails that are moved from the `Junk` back to `Inbox` are persisted in `ham`. Both folders indicate mails that should be trained as either being ham or spam.

The `kopano-scheduler` container is extended to run the training inside the `mail` docker container at about 4am with training results being picked up by SpamAssassin
automatically. You can check the docker logs of the scheduler for the results of each run.

While already trained files can be deleted immediately after each training run, there is no cleanup provided here. The `kopanospamd` volume will therefore grow over time.

For the bayes filter to start working you will need to train at least 200 mails of each ham and spam. To create a set of initial data you can use the Kopano WebApp
by selecting mails and using the `Export as` function to create a zip file of those mails and put them into the appropriate folder.

Read more about how to create effective training data here: https://spamassassin.apache.org/full/3.4.x/doc/sa-learn.html#EFFECTIVE-TRAINING
