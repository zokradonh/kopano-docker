# define some defaults https://tech.davis-hansson.com/p/make/
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

docker_repo := ecw74

base_download_version := $(shell ./version.sh core)
core_download_version := $(shell ./version.sh core)
kapps_download_version := $(shell ./version.sh kapps)
meet_download_version := $(shell ./version.sh meet)
webapp_download_version := $(shell ./version.sh webapp)
zpush_download_version := $(shell ./version.sh zpush)
vcs_ref := $(shell git rev-parse --short HEAD)

KOPANO_CORE_REPOSITORY_URL := file:/kopano/repo/core
KOPANO_KAPPS_REPOSITORY_URL := file:/kopano/repo/kapps
KOPANO_MEET_REPOSITORY_URL := file:/kopano/repo/meet
KOPANO_WEBAPP_FILES_REPOSITORY_URL := file:/kopano/repo/files
KOPANO_WEBAPP_MDM_REPOSITORY_URL := file:/kopano/repo/mdm
KOPANO_WEBAPP_REPOSITORY_URL := file:/kopano/repo/webapp
KOPANO_WEBAPP_SMIME_REPOSITORY_URL := file:/kopano/repo/smime
KOPANO_ZPUSH_REPOSITORY_URL := https://download.kopano.io/zhub/z-push:/final/Debian_10/
DOWNLOAD_COMMUNITY_PACKAGES := 1
KOPANO_UID := 999
KOPANO_GID := 999

DOCKERCOMPOSE_FILE := docker-compose.yml -f docker-compose.db.yml -f docker-compose.ldap.yml -f docker-compose.mail.yml
TAG_FILE := build.tags
-include .env
export

# convert lowercase componentname to uppercase
component ?= base
COMPONENT = $(shell echo $(component) | tr a-z A-Z)

.PHONY: default
default: help

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build-all
all: build-all

build-all:
	make $(shell grep -o ^build-.*: Makefile | grep -Ev 'build-all|build-simple|build-builder|build-webapp-demo|build-webapp-plugins' | uniq | sed s/://g | xargs)

.PHONY: build
build: component ?= base
build: ## Helper target to build a given image. Defaults to the "base" image.
ifdef TRAVIS
	@echo "fetching previous build to warm up build cache (only on travis)"
	docker pull  $(docker_repo)/kopano_$(component):builder || true
endif
ifeq (,$(wildcard ./apt_auth.conf))
	touch apt_auth.conf
endif
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build --rm \
		--build-arg VCS_REF=$(vcs_ref) \
		--build-arg docker_repo=${docker_repo} \
		--build-arg KOPANO_CORE_VERSION=${core_download_version} \
		--build-arg KOPANO_$(COMPONENT)_VERSION=${$(component)_download_version} \
		--build-arg KOPANO_CORE_REPOSITORY_URL=$(KOPANO_CORE_REPOSITORY_URL) \
		--build-arg KOPANO_KAPPS_REPOSITORY_URL=$(KOPANO_KAPPS_REPOSITORY_URL) \
		--build-arg KOPANO_MEET_REPOSITORY_URL=$(KOPANO_MEET_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_FILES_REPOSITORY_URL=$(KOPANO_WEBAPP_FILES_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_MDM_REPOSITORY_URL=$(KOPANO_WEBAPP_MDM_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_REPOSITORY_URL=$(KOPANO_WEBAPP_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_SMIME_REPOSITORY_URL=$(KOPANO_WEBAPP_SMIME_REPOSITORY_URL) \
		--build-arg KOPANO_ZPUSH_REPOSITORY_URL=$(KOPANO_ZPUSH_REPOSITORY_URL) \
		--build-arg DOWNLOAD_COMMUNITY_PACKAGES=$(DOWNLOAD_COMMUNITY_PACKAGES) \
		--build-arg ADDITIONAL_KOPANO_PACKAGES=$(ADDITIONAL_KOPANO_PACKAGES) \
		--build-arg ADDITIONAL_KOPANO_WEBAPP_PLUGINS=$(ADDITIONAL_KOPANO_WEBAPP_PLUGINS) \
		--build-arg KOPANO_UID=$(KOPANO_UID) \
		--build-arg KOPANO_GID=$(KOPANO_GID) \
		--cache-from $(docker_repo)/kopano_$(component):builder \
		--cache-from $(docker_repo)/kopano_$(component):latest \
		--secret id=repocred,src=apt_auth.conf --progress=plain \
		-t $(docker_repo)/kopano_$(component) $(component)/

.PHONY: build-simple
build-simple: component ?= ssl
build-simple: ## Helper target to build a simplified image (no Kopano repo integration).
	docker build --rm \
		--build-arg VCS_REF=$(vcs_ref) \
		--build-arg docker_repo=$(docker_repo) \
		--cache-from $(docker_repo)/kopano_$(component):latest \
		-t $(docker_repo)/kopano_$(component) $(component)/

.PHONY: build-builder
build-builder: component ?= kdav
build-builder: ## Helper target for images with a build stage.
ifdef TRAVIS
	@echo "fetching previous build to warm up build cache (only on travis)"
	docker pull  $(docker_repo)/kopano_$(component):builder || true
endif
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build --rm \
		--target builder \
		--build-arg VCS_REF=$(vcf_ref) \
		--build-arg docker_repo=${docker_repo} \
		--build-arg KOPANO_CORE_VERSION=${core_download_version} \
		--build-arg KOPANO_$(COMPONENT)_VERSION=${$(component)_download_version} \
		--build-arg KOPANO_CORE_REPOSITORY_URL=$(KOPANO_CORE_REPOSITORY_URL) \
		--build-arg KOPANO_MEET_REPOSITORY_URL=$(KOPANO_MEET_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_REPOSITORY_URL=$(KOPANO_WEBAPP_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_FILES_REPOSITORY_URL=$(KOPANO_WEBAPP_FILES_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_MDM_REPOSITORY_URL=$(KOPANO_WEBAPP_MDM_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_SMIME_REPOSITORY_URL=$(KOPANO_WEBAPP_SMIME_REPOSITORY_URL) \
		--build-arg KOPANO_ZPUSH_REPOSITORY_URL=$(KOPANO_ZPUSH_REPOSITORY_URL) \
		--build-arg DOWNLOAD_COMMUNITY_PACKAGES=$(DOWNLOAD_COMMUNITY_PACKAGES) \
		--cache-from $(docker_repo)/kopano_$(component):builder \
		-t $(docker_repo)/kopano_$(component):builder $(component)/

build-base: ## Build new base image.
	docker pull debian:buster
	component=base make build

build-core: build-base
	component=core make build

build-core-dagent: build-core
	docker build --rm \
		-f core/Dockerfile.dagent \
		--build-arg docker_repo=$(docker_repo) \
		-t $(docker_repo)/kopano_dagent core/

build-helper:
	component=build make build-simple

build-kapps: build-base
	component=kapps make build

build-konnect:
	component=konnect make build-simple

build-kwmbridge:
	component=kwmbridge make build-simple

build-kwmserver:
	component=kwmserver make build-simple

build-ldap:
	component=ldap make build-simple

build-ldap-demo: build-ldap
	component=ldap_demo make build-simple

build-meet: build-base
	component=meet make build

build-php: build-base
	component=php make build

build-playground:
	component=playground make build-builder
	component=playground make build-simple

build-python: build-base
	component=python make build

build-kdav: build-php
	docker pull composer:1.9
	component=kdav make build-builder
	component=kdav make build

build-scheduler:
	docker pull docker:19.03
	component=scheduler make build-simple

build-ssl:
	docker pull alpine:3.11
	component=ssl make build-simple

build-utils: build-core
	component=utils make build

build-web:
	component=web make build-simple

build-webapp: build-php
	component=webapp make build

build-webapp-demo: build-webapp ## Replaces the actual kopano_webapp container with one that has login hints for demo.kopano.com.
	docker build --rm \
		--build-arg docker_repo=$(docker_repo) \
		-f webapp/Dockerfile.demo \
		-t $(docker_repo)/kopano_webapp webapp/

build-webapp-plugins: ## Example for a custom image to install Kopano WebApp plugins
	docker build --rm \
		--build-arg docker_repo=$(docker_repo) \
		-f webapp/Dockerfile.plugins \
		-t $(docker_repo)/kopano_webapp webapp/

build-zpush: build-php
	component=zpush make build

tag-all: build-all ## Helper target to create tags for all images.
	make $(shell grep -o ^tag-.*: Makefile | grep -Ev 'tag-all|tag-container' | uniq | sed s/://g | xargs)

tag-container: component ?= base
tag-container: ## Helper target to tag a given image. Defaults to the base image.
	@echo 'create tag $($(component)_version)'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):${$(component)_version}
	@version=$($(component)_version); while [[ $$version == *.* ]]; do \
		version=$${version%.*} ; \
		docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):$$version ; \
	done
	@echo $(docker_repo)/kopano_$(component):${$(component)_version} >> $(TAG_FILE)
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):latest
	git commit -m 'ci: committing changes for $(component)' -- $(component) || true
	git tag $(component)/${$(component)_version} || true

tag-base:
	$(eval base_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_base))
	component=base make tag-container

tag-core:
	$(eval core_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_core | cut -d+ -f1))
	component=core make tag-container

tag-dagent:
	$(eval dagent_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_dagent | cut -d+ -f1))
	component=dagent make tag-container

tag-kapps:
	$(eval kapps_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_kapps  | cut -d+ -f1))
	component=kapps make tag-container

tag-konnect:
	$(eval konnect_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_konnect))
	component=konnect make tag-container

tag-kwmbridge:
	$(eval kwmbridge_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_kwmbridge))
	component=kwmbridge make tag-container

tag-kwmserver:
	$(eval kwmserver_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_kwmserver))
	component=kwmserver make tag-container

tag-ldap:
	$(eval ldap_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_ldap))
	component=ldap make tag-container
	$(eval ldap_demo_version := $(ldap_version))
	component=ldap_demo make tag-container

tag-meet:
	$(eval meet_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_meet | cut -d+ -f1))
	component=meet make tag-container

tag-php:
	$(eval php_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_php | cut -d- -f1))
	component=php make tag-container

tag-python:
	$(eval python_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_python | cut -d- -f1))
	component=python make tag-container

tag-scheduler:
	$(eval scheduler_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_scheduler))
	component=scheduler make tag-container

tag-ssl:
	$(eval ssl_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_ssl))
	component=ssl make tag-container

tag-utils:
	$(eval utils_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_utils | cut -d- -f1))
	component=utils make tag-container

tag-web:
	$(eval web_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_web))
	component=web make tag-container

tag-webapp:
	$(eval webapp_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_webapp | cut -d+ -f1))
	component=webapp make tag-container

tag-zpush:
	$(eval zpush_version := \
	$(shell docker inspect --format '{{ index .Config.Labels "org.label-schema.version"}}' $(docker_repo)/kopano_zpush | cut -d+ -f1))
	component=zpush make tag-container

# Docker publish

.PHONY: publish
publish:
	make $(shell grep -o ^publish-.*: Makefile | grep -Ev 'publish-container' | uniq | sed s/://g | xargs)

publish-container: component ?= base
publish-container: ## Helper target to push a given image to a registry. Defaults to the base image.
	@echo 'publish latest to $(docker_repo)/kopano_$(component)'
	docker push $(docker_repo)/kopano_$(component):${$(component)_version}
	@version=$($(component)_version); while [[ $$version == *.* ]]; do \
		version=$${version%.*} ; \
		docker push $(docker_repo)/kopano_$(component):$$version ; \
	done
ifdef PUBLISHLATEST
	docker push $(docker_repo)/kopano_$(component):latest
endif
#ifdef DOCKERREADME
#	bash .ci/docker-hub-helper.sh $(component)
#endif

publish-base: tag-base
	component=base make publish-container

publish-core: tag-core
	component=core make publish-container

publish-dagent: tag-dagent
	component=dagent make publish-container

publish-helper:
	docker push $(docker_repo)/kopano_build:latest

publish-kapps: tag-kapps
	component=kapps make publish-container

publish-konnect: tag-konnect
	component=konnect make publish-container

publish-kwmbridge: tag-kwmbridge
	component=kwmbridge make publish-container

publish-kwmserver: tag-kwmserver
	component=kwmserver make publish-container

publish-ldap: tag-ldap
	component=ldap make publish-container

publish-ldap-demo: tag-ldap
	component=ldap_demo make publish-container

publish-meet: tag-meet
	component=meet make publish-container

publish-php: tag-php
	component=php make publish-container

publish-playground:
	docker push $(docker_repo)/kopano_playground:latest
	docker push $(docker_repo)/kopano_playground:builder

publish-python: tag-python
	component=python make publish-container

publish-kdav: #tag-kdav
	docker push $(docker_repo)/kopano_kdav:latest
	docker push $(docker_repo)/kopano_kdav:builder

publish-scheduler: tag-scheduler
	component=scheduler make publish-container

publish-ssl: tag-ssl
	component=ssl make publish-container

publish-utils: tag-utils
	component=utils make publish-container

publish-web: tag-web
	component=web make publish-container

publish-webapp: tag-webapp
	component=webapp make publish-container

publish-zpush: tag-zpush
	component=zpush make publish-container

lint:
	git ls-files | xargs eclint check
	grep -rIl '^#![[:blank:]]*/bin/\(bash\|sh\|zsh\)' \
	--exclude-dir=.git --exclude=*.sw? \
	| xargs shellcheck -x
	git ls-files --exclude='*.yml' --ignored | xargs --max-lines=1 yamllint
	# List files which name starts with 'Dockerfile'
	# eg. Dockerfile, Dockerfile.build, etc.
	git ls-files --exclude='Dockerfile*' --ignored | xargs --max-lines=1 hadolint

.PHONY: clean
clean:
	docker ps --filter name=kopano_test* -aq | xargs docker rm -f || true
	docker-compose -f $(DOCKERCOMPOSE_FILE) down -v --remove-orphans || true

.PHONY: clean-all-images
clean-all-images:
	docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '${docker_repo}/kopano_') | grep -v '<none>'

.PHONY: clean-all-containers
clean-all-containers:
	docker ps -a | awk '{ print $$1,$$2 }' | grep '$(docker_repo)/kopano_' | awk '{print $$1 }' | xargs -I {} docker rm {}

.PHONY: test
test: ## Build and start new containers for testing (also deletes existing data volumes).
	docker-compose -f $(DOCKERCOMPOSE_FILE) down -v --remove-orphans || true
	make build-all
	docker-compose -f $(DOCKERCOMPOSE_FILE) build
	docker-compose -f $(DOCKERCOMPOSE_FILE) up -d
	docker-compose -f $(DOCKERCOMPOSE_FILE) ps

test-update-env: ## Recreate containers based on updated .env.
	docker-compose -f $(DOCKERCOMPOSE_FILE) up -d

.PHONY: test-ci
test-ci: test-startup

.PHONY: test-startup
test-startup: clean ## Test if all containers start up
	docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml build
	docker-compose -f $(DOCKERCOMPOSE_FILE) up -d
	docker-compose -f $(DOCKERCOMPOSE_FILE) ps
	docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml run test || \
		(docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml ps; \
		docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml logs -t --tail=50; \
		docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml stop; \
		docker ps --filter name=kopano_test* -aq | xargs docker rm -f; \
		exit 1)
	docker-compose -f $(DOCKERCOMPOSE_FILE) -f tests/test-container.yml stop 2>/dev/null
	docker ps --filter name=kopano_test* -aq | xargs docker rm -f

.PHONY: test-startup-meet-demo
test-startup-meet-demo: ## Test if the Meet demo setup starts up
	docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml build
	docker-compose -f examples/meet/docker-compose.yml up -d
	docker-compose -f examples/meet/docker-compose.yml ps
	docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml run test || \
		(docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml ps; \
		docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml logs -t --tail=20; \
		docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml stop; \
		docker ps --filter name=kopano_test* -aq | xargs docker rm -f; \
		exit 1)
	docker-compose -f examples/meet/docker-compose.yml -f examples/meet/tests/test-container.yml stop 2>/dev/null
	docker ps --filter name=kopano_test* -aq | xargs docker rm -f

.PHONY: test-startup-individual
test-startup-individual:
	docker run -it --rm -e DEBUG=true -v /etc/machine-id:/etc/machine-id -v /etc/machine-id:/var/lib/dbus/machine-id kopano/kopano_konnect

# TODO this needs goss added to travis and dcgoss pulled from my own git repo
.PHONY: test-goss
test-goss: ## Test configuration of containers with goss
	GOSS_FILES_PATH=core/goss/server dcgoss run kopano_server
	GOSS_FILES_PATH=core/goss/dagent dcgoss run kopano_dagent
	GOSS_FILES_PATH=core/goss/gateway dcgoss run kopano_gateway
	GOSS_FILES_PATH=core/goss/ical dcgoss run kopano_ical
	GOSS_FILES_PATH=core/goss/grapi dcgoss run kopano_grapi
	GOSS_FILES_PATH=core/goss/kapi dcgoss run kopano_kapi
	GOSS_FILES_PATH=core/goss/monitor dcgoss run kopano_monitor
	GOSS_FILES_PATH=core/goss/search dcgoss run kopano_search
	GOSS_FILES_PATH=core/goss/spooler dcgoss run kopano_spooler
	GOSS_FILES_PATH=meet dcgoss run kopano_meet
	GOSS_FILES_PATH=scheduler dcgoss run kopano_scheduler
	GOSS_FILES_PATH=webapp dcgoss run kopano_webapp

test-commander: ## Test scripts with commander
	commander test tests/commander.yaml
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=core/commander/server dccommander run kopano_server
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=core/commander/spooler dccommander run kopano_spooler
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=core/commander/grapi dccommander run kopano_grapi
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=webapp dccommander run kopano_webapp
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=zpush dccommander run kopano_zpush
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=konnect dccommander run kopano_konnect
	COMMANDER_OPTS="--concurrent 1" COMMANDER_FILES_PATH=scheduler dccommander run kopano_scheduler
	# this test will fail if you are not on a whitelisted ip
	commander test tests/commander-supported.yaml || true

test-security: ## Scan containers with Trivy for known security risks (not part of CI workflow for now).
	cat $(TAG_FILE) | xargs -I % sh -c 'trivy --exit-code 0 --severity HIGH --quiet --auto-refresh %'
	cat $(TAG_FILE) | xargs -I % sh -c 'trivy --exit-code 1 --severity CRITICAL --quiet --auto-refresh %'
	rm $(TAG_FILE)

test-quick: ## Similar to test target, but does not delete existing data volumes and does not rebuild images.
	docker-compose -f $(DOCKERCOMPOSE_FILE) stop || true
	docker-compose -f $(DOCKERCOMPOSE_FILE) up -d
	docker-compose -f $(DOCKERCOMPOSE_FILE) ps

test-stop:
	docker-compose -f $(DOCKERCOMPOSE_FILE) stop || true
