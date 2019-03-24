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

build-all: build-base build-core build-kdav build-konnect build-kwmserver build-ldap-demo build-meet build-playground build-scheduler build-ssl build-utils build-web build-webapp build-zpush

.PHONY: build
build: component ?= base
build:
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
		-t $(docker_repo)/kopano_$(component) $(component)/

.PHONY: build-simple
build-simple: component ?= ssl
build-simple:
	docker build -t $(docker_repo)/kopano_$(component) $(component)/

build-base:
	component=base make build

build-core:
	component=core make build

build-konnect:
	component=konnect make build-simple

build-kwmserver:
	component=kwmserver make build-simple

build-ldap-demo:
	component=ldap_demo make build-simple

build-meet:
	component=meet make build

build-playground:
	component=playground make build-simple

build-kdav:
	component=kdav make build

build-scheduler:
	component=scheduler make build-simple

build-ssl:
	component=ssl make build-simple

build-utils: build-core
	component=utils make build

build-web:
	component=web make build-simple

build-webapp:
	component=webapp make build

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

tag-scheduler:
	$(eval scheduler_version := \
	$(shell docker run --rm $(docker_repo)/kopano_scheduler env | grep SUPERCRONIC_VERSION | cut -d'=' -f2))
	component=scheduler make tag-container

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

publish: repo-login publish-base publish-core publish-kdav publish-konnect publish-kwmserver publish-meet publish-playground publish-scheduler publish-ssl publish-utils publish-web publish-webapp publish-zpush

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

publish-meet: build-meet tag-meet
	component=meet make publish-container

publish-playground: build-playground
	docker push $(docker_repo)/kopano_playground:latest

publish-kdav: build-kdav #tag-kdav
	#component=zpush make publish-container
	docker push $(docker_repo)/kopano_kdav:latest

publish-scheduler: build-scheduler tag-scheduler
	component=scheduler make publish-container

publish-ssl: build-ssl
	docker push $(docker_repo)/kopano_ssl:latest

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
	| xargs shellcheck
	# List files which name starts with 'Dockerfile'
	# eg. Dockerfile, Dockerfile.build, etc.
	git ls-files --exclude='Dockerfile*' --ignored | xargs --max-lines=1 hadolint

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

default: build-all
