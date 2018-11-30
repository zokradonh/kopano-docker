# (unofficial) Kopano Docker Images

This repository contains an easy to replicate recipe to spin up a [Kopano](https://kopano.com/) demo enviroment, which can (through modification of `.env` and possibly `docker-compose.yml`) also be used for production environments.

## How to get started?

- make sure that you are running a recent enought version of Docker and [Docker Compose](https://docs.docker.com/compose/install/)
- clone this repository to your local disk
- run `setup.sh`
  - this script will ask you a few questions about your environment.
  - If you are just interested in the demo environment you can accept the default values by pressing `Enter` on each question
  - afterwards it builds a local image for the demo LDAP
- now run `docker-compose up` and you will see how the remaining Docker images are pulled and then everything is started
- after startup has succeeded you can access the Kopano WebApp by going to `https://kopano.demo/webapp`
- you can also access phpLDAPadmin by going to `https://kopano.demo/ldap-admin`

**Note:** There have been reports about the ldap demo not starting up on MacOS. It is recommended to use a Linux OS if you want to use the bundled LDAP image. 

The `docker-compose.yml` file by default pulls Docker containers from https://hub.docker.com/r/zokradonh/kopano_core/ and https://hub.docker.com/r/zokradonh/kopano_webapp/. These images are based on the [Kopano nightly builds](https://download.kopano.io/community/) and will contain the latest version available from the time the image was built.

### Need to adjust any values after the initial run of `setup.sh`?

If you want to modify some of the values from the `setup.sh` run you can simply edit `.env` in your favourite editor. Repeated runs of `setup.sh` will neither modify `docker-compose.yml` nor `.env`. In that file you will also find some given defaults like ldap query filters and the local ports for the reverse proxy.

### How to use a newer version than the one available from the Docker Hub?

In this repository you can also find a Makefile that automates the process of building newer images.

You can easily rebuild all images based on the currently available Kopano version by running `make build-all`. To just rebuild a certain image you can also run `make build-core` or `make build-webapp`. Please check the `Makefile` to see other possible targets. (depending on your environment you may also be able to autocomplete with the `Tab` key)

To be able to easily go back to a previous version you can also "tag" you Docker images by running e.g. `make tag-core`.

### How to use the project with the official and supported Kopano releases?

This project also makes it possible to build Docker images based on the official Kopano releases. For this the following section needs to be modified in `.env`:

```
# Docker Repository to push to
#docker_repo=zokradonh

# modify below to build a different version, than the kopano nightly release
#KOPANO_CORE_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/core:/final/Debian_9.0/
#KOPANO_WEBAPP_REPOSITORY_URL=https://serial:REPLACE-ME@download.kopano.io/supported/webapp:/final/Debian_9.0/
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
- The `kopano_zpush` image is accessible on port 80 and servers Z-Push on `/Microsoft-Server-ActiveSync` (additional urls may be needed in the future see #39).

### I want to use these Docker images outside of an evaluation environment. What do I need to adjust to make this possible?

To get a quick impression of Kopano this git repository bundles a locally build ldap image with some example users. When using the docker-compose.yml in a production environment make sure to:

- either remove `ldap-demo/bootstrap/ldif/demo-users.ldif` from the locally built ldap image or complelty remove the local ldap from the compose file
- adapt ldap queries in .env to match you actual ldap server and users
- all additional configuration of the Kopano components should be specified in the compose file and **not within the running container**

### Some more commands for those unfamilar with docker-compose

- Start ``docker-compose-yml`` file in the background: `docker-compose up -d`
- Get a status overview of the running containers: `docker-compose ps`
- Stop compose running in the background: `docker-compose stop`
- Destroy local containers and network interfaces: `docker-compose down`
- Run commands in a running container: `docker-compose exec kserver kopano-cli --list-users`
- Get logs of a container running in the background: `docker-compose logs -f kserver`
- Run a `kopano-backup`: `docker run -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_core kopano-backup`
- Get a shell in a new container to for example run `kopano-migration-pst` (would still need to be installed first): `docker run -it -v /var/run/kopano/:/var/run/kopano -v $(pwd):/kopano/path zokradonh/kopano_core bash`

## Third party docker images

The example `docker-compose.yml` uses the following components for the MTA (mail delivery, including anti-spam & anti-virus) and openLDAP. Please consult their documentation for further configuration advice.

- https://github.com/tomav/docker-mailserver/
- https://github.com/osixia/docker-openldap
- https://github.com/osixia/docker-phpLDAPadmin
