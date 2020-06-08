# (unofficial) Kopano Docker Images

[![Build Status](https://travis-ci.com/zokradonh/kopano-docker.svg?branch=master)](https://travis-ci.com/zokradonh/kopano-docker)

This repository contains an easy to replicate recipe to spin up a [Kopano](https://kopano.com/) demo environment, which can (through modification of `.env` and possibly `docker-compose.yml`/`docker-compose.override.yml`) also be used for production environments.

## How to get started?

- make sure that you are running at least Docker 17.06.0 and [Docker Compose](https://docs.docker.com/compose/install/) 1.19.0.
- clone this repository to your local disk
- run `setup.sh`:
  - this script will ask you a few questions about your environment
  - If you are just interested in the demo environment you can accept the default values by pressing `Enter` on each question
- now run `docker-compose up` and you will see how the remaining Docker images are pulled and then everything is started
- after startup has succeeded you can access the Kopano WebApp by going to `https://kopano.demo/webapp`
- there are already some users created in the demo LDAP
  - these users all have a password that is identical to the username, e.g. the password for `user1` user `user1`
- to build own containers at least Docker 19.03 is required
  - this is due to the usage of build-time secrets

If you want to get an impression how the containers interact/relate with each other have a look at the [architecture](ARCHITECTURE.md) description.

**Note:** There have been reports about the LDAP demo not starting up on MacOS. It is recommended to use a Linux OS if you want to use the bundled LDAP image.

The `docker-compose.yml` file by default pulls Docker containers from for example https://hub.docker.com/r/zokradonh/kopano_core/ and https://hub.docker.com/r/zokradonh/kopano_webapp/. These images are based on the [Kopano nightly builds](https://download.kopano.io/community/) and will contain the latest version available from the time the image was built.

## Troubleshooting

If you are running into a problem please include the following issues in the description of your report:

- the error message produced when running `docker-compose up`
  - or the output of `docker-compose ps`
- for failed containers the output of `docker-compose logs $containername`
- the contents of your `.env`
- either the output of `docker-compose config` (only useful when `docker-compose up` succeeds) or your `docker-compose.yml`
- the output of `docker -v` and `docker-compose -v`

Please make sure to remove sensitive data (for example your real hostname or passwords for accounts) when posting these information publicly.

If you have problems or questions about Kopano in general then either get in contact with the [Kopano support](https://kopano.com/support-info/) (if you have a valid subscription) or start a topic on the [Kopano forum](https://forum.kopano.io/).

## Updating

The used `docker-compose.yml` is part of the git versioning. Which mean all changes in this repository will also be applied to your local data once you pull in the latest version. If you need to configure additional env variables, this can now be done in the additional env files (more details further below, for example for `kopano_server` this file is called `kopano_server.env`). If you only want to run a subset of containers it is recommended to create a copy of `docker-compose.yml` and specify your copy when running. e.g. like `docker-compose -f my-setup.yml up -d`.

## Is this project also interesting for me when I already have a (non-Docker) Kopano environment?

Yes, indeed. You could for example use this to easily try out newer Kopano WebApp or Z-Push releases, without touching your production environment. Through the `zokradonh/kopano_core` image you could even try out newer version of e.g. `kopano-gateway` without jumping into a dependency mess in your production environment.

And last but not least this project also offers a `zokradonh/kopano_utils` image to easily run tools such as `kopano-backup`, `kopano-migration-pst`, `kopano-migration-imap` and all the other utilities that are bundles with Kopano. See [below](#some-more-commands-for-those-unfamiliar-with-docker-compose) to see how to run `zokradonh/kopano_utils`.

### Additional configuration / Need to adjust any values after the initial run of `setup.sh`?

If you want to modify some of the values from the `setup.sh` run you can simply edit `.env` in your favorite editor. Repeated runs of `setup.sh` will neither modify `docker-compose.yml` nor `.env`. In the ´.env´ file you will also find some given defaults like LDAP query filters and the local ports for the reverse proxy.

Additionally a dedicated env file is created for each container (at least where that would make sense). The env file has the container name as part of the file name. For example for the `kopano_server` container the filename is named `kopano_server.env`. These additional env files are auto created when running `setup.sh`.

Any additional configuration should be done through environment variables and not done in the actual container. The images working with configuration files (e.g. `kopano_core`, `kopano_webapp`, `kopano_meet`) have a mechanism built in to translate env variables into configuration files. For services that can directly work with env variables (e.g. `kopano_konnect`, `kopano_kwmserver`) these can be specified directly. Please check the individual `README.md` files for further instructions.

The compose file itself is part of the git repository and should not be edited directly. Instead a `docker-compose.override.yml` file (will be ignored by git) can be created to override and extend the default one. See https://docs.docker.com/compose/extends/ for more information.

#### Why is my compose override file ignored?

This project uses the `COMPOSE_FILE` environment variable to allow users to override the ports exposed by each container (for example when using a different front facing proxy). When using a `docker-compose.override.yml` file make sure this is included in this variable in the `.env` file. For example like this:

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose.portmapping.yml:docker-compose.override.yml
```

#### I've pulled in the latest version, but now I cannot reach Kopano over the network any longer!

This project switched to specifying `COMPOSE_FILE` in `.env` to allow users to easily disable individual ports exposed. Please rerun `setup.sh` to add this variable to your `.env` file or add it manually.

### How to use a newer version than the one available from the Docker Hub?

In this repository you can also find a Makefile that automates the process of building newer images.

You can easily rebuild all images based on the currently available Kopano version by running `make build-all`. To just rebuild a certain image you can also run `make build-core` or `make build-webapp`. Please check the `Makefile` to see other possible targets. (depending on your environment you may also be able to autocomplete with the `Tab` key)

To be able to easily go back to a previous version you can also "tag" you Docker images by running e.g. `make tag-core`.

### Recurring tasks and maintenance tasks within Kopano

There are certain tasks within Kopano that either need to be executed once (like creating the public store when starting a new environment for the first time) or on a regular base (like syncing the internal user list with and external LDAP tree). For convenience this project includes a `scheduler` container that will take care of this and that can be dynamically configured through env variables.

Please check the `README.md` of the scheduler image for further instructions.

Instead of using the internal scheduler one can also just use an existing scheduler (cron on the docker host for example) to execute these tasks.

### How to use the project with the official and supported Kopano releases?

This project also makes it possible to build Docker images based on the official Kopano releases. For this the following section needs to be modified in `.env`:

```bash
# Docker Repository to push to/pull from
docker_repo=zokradonh
COMPOSE_PROJECT_NAME=kopano
COMPOSE_FILE=docker-compose.yml:docker-compose.ports.yml:docker-compose.db.yml:docker-compose.ldap.yml:docker-compose.mail.yml

# Modify below to build a different version, than the Kopano nightly release
# credentials for repositories are handled through a file called apt_auth.conf (which will be created through setup.sh or Makefile)
#KOPANO_CORE_REPOSITORY_URL=https://download.kopano.io/supported/core:/8.7/Debian_10/
#KOPANO_MEET_REPOSITORY_URL=https://download.kopano.io/supported/meet:/final/Debian_10/
#KOPANO_WEBAPP_REPOSITORY_URL=https://download.kopano.io/supported/webapp:/final/Debian_10/
#KOPANO_WEBAPP_FILES_REPOSITORY_URL=https://download.kopano.io/supported/files:/final/Debian_10/
#KOPANO_WEBAPP_MDM_REPOSITORY_URL=https://download.kopano.io/supported/mdm:/final/Debian_10/
#KOPANO_WEBAPP_SMIME_REPOSITORY_URL=https://download.kopano.io/supported/smime:/final/Debian_10/
#KOPANO_ZPUSH_REPOSITORY_URL=http://repo.z-hub.io/z-push:/final/Debian_10/
#RELEASE_KEY_DOWNLOAD=1
#DOWNLOAD_COMMUNITY_PACKAGES=0
```

The credentials for the Kopano package repositories can either be defined through the url itself, e.g. like `https://serial:REPLACE-ME@download.kopano.io/supported/core:/final/Debian_10/` or through an `apt_auth.conf` file. Using `apt_auth.conf` is preferred, since it does not "leak" credentials into the final image.

With the above lines uncommented and credentials in place running `make build-all` will rebuild the images based on the latest available Kopano release (don't forget to `make tag-core` and `make tag-webapp` your images after building them).

If you are running a private Docker Registry then you have to change `docker_repo` to reference your internal registry. Afterward you can run for example `make publish-core` to push the image to your registry.

***WARNING***

When storing the credentials in the url the built image will include your subscription key! Do not push this image to any public registry like e.g. https://hub.docker.com!

### When building my own containers, how can I make sure my build works as expected?

Please check the [contributing information](CONTRIBUTING.md).

### What if I want to use a different front facing proxy than the one in docker-compose? Or just some part of the compose file?

While using kweb is recommended, this is of course possible.

Please check the individual web containers (kDAV, WebApp and Z-Push for individual instructions).

### How can I prevent e.g. `kopano-gateway` to be reachable from the network?

The exposed ports of each container are defined in `docker-compose.ports.yml`. If you do not want to expose some of the containers to the network, it is recommended to copy this file to `docker-compose.override.yml`and just remove all entries that you do not want to have exposed.

### I want to use these Docker images outside of an evaluation environment. What do I need to adjust to make this possible?

To get a quick impression of Kopano this git repository bundles a locally build LDAP image with some example users. When using the docker-compose.yml in a production environment make sure to:

- switch to the non-demo ldap tree or completely remove the local LDAP from the compose file
- adapt LDAP queries in .env to match you actual LDAP server and users
- all additional configuration of the Kopano components should be specified in the compose file/the env file/an override and **not within the running container**
- make sure that there is a unique machine-id for your deployment
  - the default setup mounts the file from the host, if your host is running multiple installations of Kopano make sure to generate a unique value for each installation.

#### Can I combine these Docker images with my existing environment?

Yes, that is certainly a possibility. Within the `examples/` directory you can find some ready to run examples that can be run in the following way:

- `docker-compose -f examples/webapp.yml up -d`

### Some more commands for those unfamiliar with docker-compose

- Start ``docker-compose.yml`` file in the background: `docker-compose up -d`
- Get a status overview of the running containers: `docker-compose ps`
- Stop compose running in the background: `docker-compose stop`
- Destroy local containers and network interfaces: `docker-compose down`
- Destroy volumes as well (will completely reset the containers, **deletes all data**): `docker-compose down -v`
- Run commands in a running container: `docker-compose exec kopano_server kopano-cli --list-users`
- Get logs of a in the background running container: `docker-compose logs -f kopano_server`
- Run a `kopano-backup`: `docker run --rm -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_utils kopano-backup`
  - Same command but getting volumes from the existing `kopano_server` container: `docker run --rm -it --volumes-from kopano_server -v /root/kopano-backup:/kopano/path zokradonh/kopano_utils kopano-backup -h`
- Get a shell in a new container to (for example) run `kopano-migration-pst`: `docker run --rm -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_utils` (to directly run kopano-migration-pst just append it to the command)

### Try this project without installing Docker locally

This project includes a configuration file for [Vagrant](https://www.vagrantup.com/) to easily try kopano-docker locally. All that is required is Vagrant itself and Virtualbox.

Steps to start kopano-docker in Vagrant:

```bash
# run setup.sh
$ ./setup.sh
# provision virtual machine
$ vagrant up
# alternatively "vagrant up --provider hyperv" when running on Windows
# in case you want to connect into the machine
$ vagrant ssh
```

After the machine has started it will be reachable from the local system through the IP `10.16.73.20`, please make sure that your chosen hostname resolves to this IP. The project files are mounted to `/vagrant` in the machine. To interact with the containers just change into this directory first.

## Third party docker images

The example `docker-compose.yml` uses the following components for the MTA (mail delivery, including anti-spam & anti-virus) and openLDAP. Please consult their documentation for further configuration advice.

- https://github.com/tomav/docker-mailserver/
- https://github.com/osixia/docker-openldap
- https://github.com/osixia/docker-phpLDAPadmin

## Further reading

The following (blog) articles have been written about this project:

- https://kopano.com/blog/building-docker-containers-for-kopano/
- https://kopano.com/blog/using-docker-to-spin-up-a-kopano-environment/
