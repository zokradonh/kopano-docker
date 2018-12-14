docker_repo := zokradonh
docker_login := `cat ~/.docker-account-user`
docker_pwd := `cat ~/.docker-account-pwd`

base_version = $(shell docker run --rm $(docker_repo)/kopano_base cat /kopano/buildversion)
base_download_version := $(shell ./version.sh core)
core_version = $(shell docker run --rm $(docker_repo)/kopano_core cat /kopano/buildversion | grep -o -P '(?<=-).*(?=\+)')
core_download_version := $(shell ./version.sh core)
webapp_version = $(shell docker run --rm $(docker_repo)/kopano_webapp cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)')
webapp_download_version := $(shell ./version.sh webapp)
zpush_version = $(shell docker run --rm $(docker_repo)/kopano_zpush cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)')
zpush_download_version := $(shell ./version.sh zpush)

KOPANO_CORE_REPOSITORY_URL := file:/kopano/repo/core
KOPANO_WEBAPP_REPOSITORY_URL := file:/kopano/repo/webapp
KOPANO_ZPUSH_REPOSITORY_URL := http://repo.z-hub.io/z-push:/final/Debian_9.0/
RELEASE_KEY_DOWNLOAD := 0
DOWNLOAD_COMMUNITY_PACKAGES := 1

-include .env
export

# convert lowercase componentname to uppercase
COMPONENT = $(shell echo $(component) | tr a-z A-Z)

build-all: build-ssl build-base build-core build-webapp build-zpush build-kweb build-ldap-demo

build: component ?= base
build:
	docker build \
		--build-arg docker_repo=${docker_repo} \
		--build-arg KOPANO_CORE_VERSION=${core_download_version} \
		--build-arg KOPANO_$(COMPONENT)_VERSION=${$(component)_download_version} \
		--build-arg KOPANO_CORE_REPOSITORY_URL=$(KOPANO_CORE_REPOSITORY_URL) \
		--build-arg KOPANO_WEBAPP_REPOSITORY_URL=$(KOPANO_WEBAPP_REPOSITORY_URL) \
		--build-arg KOPANO_ZPUSH_REPOSITORY_URL=$(KOPANO_ZPUSH_REPOSITORY_URL) \
		--build-arg RELEASE_KEY_DOWNLOAD=$(RELEASE_KEY_DOWNLOAD) \
		--build-arg DOWNLOAD_COMMUNITY_PACKAGES=$(DOWNLOAD_COMMUNITY_PACKAGES) \
		--build-arg ADDITIONAL_KOPANO_PACKAGES="$(ADDITIONAL_KOPANO_PACKAGES)" \
		--build-arg ADDITIONAL_KOPANO_WEBAPP_PLUGINS="$(ADDITIONAL_KOPANO_WEBAPP_PLUGINS)" \
		-t $(docker_repo)/kopano_$(component) $(component)/

build-base:
	component=base make build

build-core:
	component=core make build

build-webapp:
	component=webapp make build

build-zpush:
	component=zpush make build

build-ssl:
	docker build -t $(docker_repo)/kopano_ssl ssl/

build-kweb:
	docker build -t $(docker_repo)/kopano_web kweb/

build-ldap-demo:
	docker build -t $(docker_repo)/kopano_ldap_demo ldap-demo/

tag: component ?= base
tag:
	@echo 'create tag $($(component)_version)'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):${$(component)_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):latest
	git commit -m 'ci: committing changes for $(component)' -- $(component) || true
	git tag $(component)/${$(component)_version} || true

tag-base:
	component=base make tag

tag-core:
	component=core make tag

tag-webapp:
	component=webapp make tag

tag-zpush:
	component=zpush make tag

# Docker publish
repo-login:
	docker login -u $(docker_login) -p $(docker_pwd)

publish: repo-login publish-ssl publish-base publish-core publish-webapp
	git push
	git push origin --tags

publish-container: component ?= base
publish-container:
	@echo 'publish latest to $(docker_repo)/kopano_$(component)'
	docker push $(docker_repo)/kopano_$(component):${$(component)_version}
	docker push $(docker_repo)/kopano_$(component):latest

publish-base: build-base tag-base
	component=base make publish-container

publish-core: build-core tag-core
	component=core make publish-container

publish-webapp: build-webapp tag-webapp
	component=webapp make publish-container

publish-zpush: build-zpush tag-zpush
	component=zpush make publish-container

publish-ssl: build-ssl
	docker push $(docker_repo)/kopano_ssl:latest

publish-kweb: build-kweb
	docker push $(docker_repo)/kopano_web:latest

test:
	docker-compose down -v || true
	make build-all
	docker-compose build
	docker-compose up -d
