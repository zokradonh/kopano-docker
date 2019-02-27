# (unofficial) Kopano Docker Images
[![Build Status](https://travis-ci.com/zokradonh/kopano-docker.svg?branch=master)](https://travis-ci.com/zokradonh/kopano-docker)

This repository contains an easy to replicate recipe to spin up a [Kopano](https://kopano.com/) demo environment, which can (through modification of `.env` and possibly `docker-compose.yml`) also be used for production environments.

## How to get started?

- make sure that you are running a recent enought version of Docker and [Docker Compose](https://docs.docker.com/compose/install/)
- clone this repository to your local disk
- run `setup.sh`
  - this script will ask you a few questions about your environment.
  - If you are just interested in the demo environment you can accept the default values by pressing `Enter` on each question
- now run `docker-compose up` and you will see how the remaining Docker images are pulled and then everything is started
- after startup has succeeded you can access the Kopano WebApp by going to `https://kopano.demo/webapp`
- there are already some users created in the demo ldap. These users all have a password that is identical to the username, e.g. the password for `user1` user `user1`.
- you can also access phpLDAPadmin by going to `https://kopano.demo/ldap-admin`
  - you can access the ldap-admin web frontent in readonly mode with: `LDAP_BIND_DN` env var as login dn and the `LDAP_BIND_PW` env var provided by the .env file (which is generated by the setup.sh)
  - if you want to modify the ldap content you can access the ldap-admin web frontend by using the `cn=admin,` appending the `LDAP_BASE_DN` env var as the login dn and `LDAP_ADMIN_PASSWORD` as the password
  - lookup kopano documentation on how to manage users using the ldap interface: https://documentation.kopano.io/kopanocore_administrator_manual/user_management.html#user-management-from-openldap

**Note:** There have been reports about the ldap demo not starting up on MacOS. It is recommended to use a Linux OS if you want to use the bundled LDAP image. 

The `docker-compose.yml` file by default pulls Docker containers from https://hub.docker.com/r/zokradonh/kopano_core/ and https://hub.docker.com/r/zokradonh/kopano_webapp/. These images are based on the [Kopano nightly builds](https://download.kopano.io/community/) and will contain the latest version available from the time the image was built.

## Updating

Previously the `docker-compose.yml` file was not part of the git repository, which made it harder for users to pick and apply changes in the upstreamed `docker-compose.yml-example` file. This has meanwhile been changed and a `git pull` will now pull changes directly into `docker-compose.yml`. If you need to configure additional env variables, this can now be done in the additional env files (more details further below, for example for `kopano_server` this file is called `kopano_server.env`). If you only want to run a subset of containers it is recommended to create a copy of `docker-compose.yml` and specify your copy when running. e.g. like ´docker-compose -f my-setup.yml up -d´.

## Is this project also interesting for me when I already have a (non-Docker) Kopano environment?

Yes, indeed. You could for example use this to easily try out newer Kopano WebApp or Z-Push releases, without touching your production environment. Through the `zokradonh/kopano_core` image you could even try out newer version of e.g. `kopano-gateway` without jumping into a dependecy mess in your production environment.

And last but not least this project also offers a `zokradonh/kopano_utils` image to easily run tools such as `kopano-backup`, `kopano-migration-pst`, `kopano-migration-imap` and all the other utilities that are bundles with Kopano. See [below](#some-more-commands-for-those-unfamilar-with-docker-compose) to see how to run `zokradonh/kopano_utils`.

### Need to adjust any values after the initial run of `setup.sh`?

If you want to modify some of the values from the `setup.sh` run you can simply edit `.env` in your favourite editor. Repeated runs of `setup.sh` will neither modify `docker-compose.yml` nor `.env`. In the ´.env´ file you will also find some given defaults like ldap query filters and the local ports for the reverse proxy.

Additionally a dedicated env file is created for each container (at least where that would make sense). The env file has the container name as part of the file name. For example for the `kopano_server` container the filename is `kopano_server.env`. These additional env files are auto created when running `setup.sh`

### How to use a newer version than the one available from the Docker Hub?

In this repository you can also find a Makefile that automates the process of building newer images.

You can easily rebuild all images based on the currently available Kopano version by running `make build-all`. To just rebuild a certain image you can also run `make build-core` or `make build-webapp`. Please check the `Makefile` to see other possible targets. (depending on your environment you may also be able to autocomplete with the `Tab` key)

To be able to easily go back to a previous version you can also "tag" you Docker images by running e.g. `make tag-core`.

### How to use the project with the official and supported Kopano releases?

This project also makes it possible to build Docker images based on the official Kopano releases. For this the following section needs to be modified in `.env`:

```
# Docker Repository to push to/pull from
docker_repo=zokradonh
COMPOSE_PROJECT_NAME=kopano

# Modify below to build a different version, than the kopano nightly release
#KOPANO_CORE_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/core:/final/Debian_9.0/
#KOPANO_WEBAPP_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/webapp:/final/Debian_9.0/
#KOPANO_WEBAPP_FILES_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/files:/final/Debian_9.0/
#KOPANO_WEBAPP_MDM_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/mdm:/final/Debian_9.0/
#KOPANO_WEBAPP_SMIME_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/smime:/final/Debian_9.0/
#KOPANO_ZPUSH_REPOSITORY_URL=http://repo.z-hub.io/z-push:/final/Debian_9.0/
#RELEASE_KEY_DOWNLOAD=1
#DOWNLOAD_COMMUNITY_PACKAGES=0
```
Just uncomment the last four lines and insert your Kopano subscription key where it currently says `REPLACE-ME`. Once this is done a `make build-all` will rebuild the images based on the latest available Kopano release (don't forget to `make tag-core` and `make tag-webapp` your images after building them).

If you are running a private Docker Registry then you may also change `docker_repo` to reference your internal registry.

***WARNING***

The built image includes your subscription key! Do not push this image to any public registry like e.g. https://hub.docker.com!

### What if I want to use a different front facing proxy than the one in docker-compose? Or just some part of the compose file?

While using kweb is recommended, this is of course possible.

- The `kopano_webapp` image is accessible on port 80 and serves the WebApp both on `/` and `/webapp`.
- The `kopano_zpush` image is accessible on port 80 and serves Z-Push on `/Microsoft-Server-ActiveSync` (additional urls may be needed in the future see #39).

### What are and how can I use the Kapi Playground and OIDC Playground?

This project includes a Docker container to easily inspect the data returned by the Kopano Rest API (KAPI), as well as the OpenID (Connect) Service Provider. To explore these applications you need to pass the URL of the "Issuer" when opening these. For the Kapi Playground this would for example be `https://kopano.demo/kapi-playground/?iss=https://kopano.demo`. For the OIDC Playground it would be `https://kopano.demo/oidc-playground/?discovery_uri=https://kopano.demo/.well-known/openid-configuration&discovery=auto`.

### I want to use these Docker images outside of an evaluation environment. What do I need to adjust to make this possible?

To get a quick impression of Kopano this git repository bundles a locally build ldap image with some example users. When using the docker-compose.yml in a production environment make sure to:

- either remove `ldap-demo/bootstrap/ldif/demo-users.ldif` from the locally built ldap image or completely remove the local ldap from the compose file
- adapt ldap queries in .env to match you actual ldap server and users
- all additional configuration of the Kopano components should be specified in the compose file and **not within the running container**

#### Can I combine these Docker images with my existing environment?

Yes, that is certainly a possibillity. Within the `examples/` directory you can find some ready to run examples that can be run in the following way:

- `docker-compose -f examples/webapp.yml up -d`

### Some more commands for those unfamilar with docker-compose

- Start ``docker-compose-yml`` file in the background: `docker-compose up -d`
- Get a status overview of the running containers: `docker-compose ps`
- Stop compose running in the background: `docker-compose stop`
- Destroy local containers and network interfaces: `docker-compose down`
- Destroy volumes as well (will completely reset the containers, **deletes all data**): `docker-compose down -v`
- Run commands in a running container: `docker-compose exec kopano_server kopano-cli --list-users`
- Get logs of a in the background running container: `docker-compose logs -f kopano_server`
- Run a `kopano-backup`: `docker run --rm -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_utils kopano-backup`
- Get a shell in a new container to (for example) run `kopano-migration-pst`: `docker run --rm -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_utils` (to directly run kopano-migration-pst just append it to the command)

## Third party docker images

The example `docker-compose.yml` uses the following components for the MTA (mail delivery, including anti-spam & anti-virus) and openLDAP. Please consult their documentation for further configuration advice.

- https://github.com/tomav/docker-mailserver/
- https://github.com/osixia/docker-openldap
- https://github.com/osixia/docker-phpLDAPadmin
