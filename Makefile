# if not run in travis, get docker_login and _pwd from file
ifndef TRAVIS
	docker_repo := zokradonh
	docker_login := `cat ~/.docker-account-user`
	docker_pwd := `cat ~/.docker-account-pwd`
endif

base_download_version := $(shell ./version.sh core)
core_download_version := $(shell ./version.sh core)
meet_download_version := $(shell ./version.sh meet)
webapp_download_version := $(shell ./version.sh webapp)
zpush_download_version := $(shell ./version.sh zpush)

KOPANO_CORE_REPOSITORY_URL := file:/kopano/repo/core
KOPANO_MEET_REPOSITORY_URL := file:/kopano/repo/meet
KOPANO_WEBAPP_REPOSITORY_URL := file:/kopano/repo/webapp
KOPANO_WEBAPP_FILES_REPOSITORY_URL := file:/kopano/repo/files
KOPANO_WEBAPP_MDM_REPOSITORY_URL := file:/kopano/repo/mdm
KOPANO_WEBAPP_SMIME_REPOSITORY_URL := file:/kopano/repo/smime
KOPANO_ZPUSH_REPOSITORY_URL := http://repo.z-hub.io/z-push:/final/Debian_9.0/
RELEASE_KEY_DOWNLOAD := 0
DOWNLOAD_COMMUNITY_PACKAGES := 1

COMPOSE_FILE := docker-compose.yml
-include .env
export

# convert lowercase componentname to uppercase
COMPONENT = $(shell echo $(component) | tr a-z A-Z)

.PHONY: all
all: build-all

build-all: build-base build-core build-kdav build-konnect build-kwmserver build-ldap build-ldap-demo build-meet build-php build-playground build-scheduler build-ssl build-utils build-web build-webapp build-zpush

.PHONY: build
build: component ?= base
build:
ifdef TRAVIS
	@echo "fetching previous build to warm up build cache (only on travis)"
	docker pull  $(docker_repo)/kopano_$(component) || true
	docker pull  $(docker_repo)/kopano_$(component):builder || true
endif
	docker build \
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
		--build-arg RELEASE_KEY_DOWNLOAD=$(RELEASE_KEY_DOWNLOAD) \
		--build-arg DOWNLOAD_COMMUNITY_PACKAGES=$(DOWNLOAD_COMMUNITY_PACKAGES) \
		--build-arg ADDITIONAL_KOPANO_PACKAGES="$(ADDITIONAL_KOPANO_PACKAGES)" \
		--build-arg ADDITIONAL_KOPANO_WEBAPP_PLUGINS="$(ADDITIONAL_KOPANO_WEBAPP_PLUGINS)" \
		--cache-from $(docker_repo)/kopano_$(component) \
		--cache-from $(docker_repo)/kopano_$(component):builder \
		-t $(docker_repo)/kopano_$(component) $(component)/

.PHONY: build-simple
build-simple: component ?= ssl
build-simple:
ifdef TRAVIS
	@echo "fetching previous build to warm up build cache (only on travis)"
	docker pull  $(docker_repo)/kopano_$(component) || true
	docker pull  $(docker_repo)/kopano_$(component):builder || true
endif
	docker build \
	--cache-from $(docker_repo)/kopano_$(component) \
	--cache-from $(docker_repo)/kopano_$(component):builder \
	--build-arg docker_repo=$(docker_repo) \
	-t $(docker_repo)/kopano_$(component) $(component)/

.PHONY: build-builder
build-builder: component ?= kdav
build-builder:
ifdef TRAVIS
	@echo "fetching previous build to warm up build cache (only on travis)"
	docker pull  $(docker_repo)/kopano_$(component):builder || true
endif
	docker build --target builder \
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
	--build-arg RELEASE_KEY_DOWNLOAD=$(RELEASE_KEY_DOWNLOAD) \
	--build-arg DOWNLOAD_COMMUNITY_PACKAGES=$(DOWNLOAD_COMMUNITY_PACKAGES) \
	--build-arg ADDITIONAL_KOPANO_PACKAGES="$(ADDITIONAL_KOPANO_PACKAGES)" \
	--build-arg ADDITIONAL_KOPANO_WEBAPP_PLUGINS="$(ADDITIONAL_KOPANO_WEBAPP_PLUGINS)" \
	--cache-from $(docker_repo)/kopano_$(component) \
	--cache-from $(docker_repo)/kopano_$(component):builder \
	-t $(docker_repo)/kopano_$(component):builder $(component)/

build-base:
	component=base make build

build-core: build-base
	component=core make build

build-konnect:
	component=konnect make build-simple

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

build-python:
	component=python make build

build-kdav:
	component=kdav make build-builder
	component=kdav make build

build-scheduler:
	component=scheduler make build-simple

build-ssl:
	component=ssl make build-simple

build-utils: build-core
	component=utils make build

build-web:
	component=web make build-simple

build-webapp: build-php
	component=webapp make build

# replaces the actual kopano_webapp container with one that has login hints for demo.kopano.com
build-webapp-demo:
	docker build \
		-f webapp/Dockerfile.demo \
		-t $(docker_repo)/kopano_webapp webapp/

build-zpush:
	component=zpush make build

tag-container: component ?= base
tag-container:
	@echo 'create tag $($(component)_version)'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):${$(component)_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):latest
	git commit -m 'ci: committing changes for $(component)' -- $(component) || true
	git tag $(component)/${$(component)_version} || true

tag-base:
	$(eval base_version := \
	$(shell docker run --rm $(docker_repo)/kopano_base cat /kopano/buildversion))
	component=base make tag-container

tag-core:
	$(eval core_version := \
	$(shell docker run --rm $(docker_repo)/kopano_core cat /kopano/buildversion | cut -d- -f2))
	component=core make tag-container

tag-konnect:
	$(eval konnect_version := \
	$(shell docker run --rm $(docker_repo)/kopano_konnect env | grep CODE_VERSION | cut -d'=' -f2))
	component=konnect make tag-container

tag-kwmserver:
	$(eval kwmserver_version := \
	$(shell docker run --rm $(docker_repo)/kopano_kwmserver env | grep CODE_VERSION | cut -d'=' -f2))
	component=kwmserver make tag-container

tag-meet:
	$(eval meet_version := \
	$(shell docker run --rm $(docker_repo)/kopano_meet cat /kopano/buildversion | grep meet | cut -d- -f2 | cut -d+ -f1))
	component=meet make tag-container

tag-php:
	$(eval php_version := \
	$(shell docker run --rm $(docker_repo)/kopano_php cat /kopano/buildversion | cut -d- -f2))
	component=php make tag-container

tag-python:
	$(eval python_version := \
	$(shell docker run --rm $(docker_repo)/kopano_python cat /kopano/buildversion | cut -d- -f2))
	component=python make tag-container

tag-scheduler:
	$(eval scheduler_version := \
	$(shell docker run --rm $(docker_repo)/kopano_scheduler env | grep SUPERCRONIC_VERSION | cut -d'=' -f2))
	component=scheduler make tag-container

tag-ssl:
	$(eval ssl_version := \
	$(shell docker run --rm $(docker_repo)/kopano_ssl env | grep CODE_VERSION | cut -d'=' -f2))
	component=ssl make tag-container

tag-utils:
	$(eval utils_version := \
	$(shell docker run --rm $(docker_repo)/kopano_utils cat /kopano/buildversion | cut -d- -f2))
	component=utils make tag-container

tag-web:
	$(eval web_version := \
	$(shell docker run --rm $(docker_repo)/kopano_web env | grep CODE_VERSION | cut -d'=' -f2))
	component=web make tag-container

tag-webapp:
	$(eval webapp_version := \
	$(shell docker run --rm $(docker_repo)/kopano_webapp cat /kopano/buildversion | grep webapp | cut -d- -f2 | cut -d+ -f1))
	component=webapp make tag-container

tag-zpush:
	$(eval zpush_version := \
	$(shell docker run --rm $(docker_repo)/kopano_zpush cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)'))
	component=zpush make tag-container

# Docker publish
repo-login:
	@docker login -u $(docker_login) -p $(docker_pwd)

.PHONY: publish
publish: repo-login publish-base publish-core publish-kdav publish-konnect publish-kwmserver publish-ldap-demo publish-meet publish-php publish-playground publish-python publish-scheduler publish-ssl publish-utils publish-web publish-webapp publish-zpush

publish-container: component ?= base
publish-container:
	@echo 'publish latest to $(docker_repo)/kopano_$(component)'
	docker push $(docker_repo)/kopano_$(component):${$(component)_version}
	docker push $(docker_repo)/kopano_$(component):latest

publish-base: build-base tag-base
	component=base make publish-container

publish-core: build-core tag-core
	component=core make publish-container

publish-konnect: build-konnect tag-konnect
	component=konnect make publish-container

publish-kwmserver: build-kwmserver tag-kwmserver
	component=kwmserver make publish-container

publish-ldap: build-ldap
	docker push $(docker_repo)/kopano_ldap:latest

publish-ldap-demo: build-ldap-demo
	docker push $(docker_repo)/kopano_ldap_demo:latest

publish-meet: build-meet tag-meet
	component=meet make publish-container

publish-php: build-php tag-php
	component=php make publish-container

publish-playground: build-playground
	docker push $(docker_repo)/kopano_playground:latest
	docker push $(docker_repo)/kopano_playground:builder

publish-python: build-python tag-python
	component=python make publish-container

publish-kdav: build-kdav #tag-kdav
	docker push $(docker_repo)/kopano_kdav:latest
	docker push $(docker_repo)/kopano_kdav:builder

publish-scheduler: build-scheduler tag-scheduler
	component=scheduler make publish-container

publish-ssl: build-ssl tag-ssl
	component=scheduler make publish-container

publish-utils: build-core build-utils tag-utils
	component=utils make publish-container

publish-web: build-web tag-web
	component=web make publish-container

publish-webapp: build-webapp tag-webapp
	component=webapp make publish-container

publish-zpush: build-zpush tag-zpush
	component=zpush make publish-container

check-scripts:
	grep -rIl '^#![[:blank:]]*/bin/\(bash\|sh\|zsh\)' \
	--exclude-dir=.git --exclude=*.sw? \
	| xargs shellcheck -x
	# List files which name starts with 'Dockerfile'
	# eg. Dockerfile, Dockerfile.build, etc.
	git ls-files --exclude='Dockerfile*' --ignored | xargs --max-lines=1 hadolint

.PHONY: clean
clean:
	docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans || true

.PHONY: test
test:
	docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans || true
	make build-all
	docker-compose -f $(COMPOSE_FILE) build
	docker-compose -f $(COMPOSE_FILE) up -d
	docker-compose -f $(COMPOSE_FILE) ps

test-update-env:
	docker-compose -f $(COMPOSE_FILE) up -d

test-ci:
	docker-compose -f $(COMPOSE_FILE) -f tests/test-container.yml build
	docker-compose -f $(COMPOSE_FILE) -f tests/test-container.yml up -d
	docker-compose -f $(COMPOSE_FILE) -f tests/test-container.yml ps
	docker wait kopano_test_1
	docker logs --tail 10 kopano_test_1
	docker-compose -f $(COMPOSE_FILE) -f tests/test-container.yml stop 2>/dev/null

test-quick:
	docker-compose -f $(COMPOSE_FILE) stop || true
	docker-compose -f $(COMPOSE_FILE) up -d
	docker-compose -f $(COMPOSE_FILE) ps

test-stop:
	docker-compose -f $(COMPOSE_FILE) stop || true

.PHONY: default
default: build-all
