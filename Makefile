docker_repo := zokradonh
docker_login := `cat ~/.docker-account-user`
docker_pwd := `cat ~/.docker-account-pwd`

base_version = $(shell docker run --rm $(docker_repo)/kopano_base cat /kopano/buildversion)
base_download_version = $(shell ./version.sh core)
core_version = $(shell docker run --rm $(docker_repo)/kopano_core cat /kopano/buildversion | grep -o -P '(?<=-).*(?=_)')
core_download_version = $(shell ./version.sh core)
webapp_version = $(shell docker run --rm $(docker_repo)/kopano_webapp cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)')
webapp_download_version = $(shell ./version.sh webapp)

COMPONENT = $(shell echo $(component) | tr a-z A-Z)

build-all: build-base build-core build-webapp

build: component ?= base
build:
	docker build --build-arg KOPANO_$(COMPONENT)_VERSION=${$(component)_download_version} -t $(docker_repo)/kopano_$(component) $(component)/

build-base:
	component=base make build

build-core:
	component=core make build

build-webapp:
	component=webapp make build

tag: component ?= base
tag:
	@echo 'create tag $($(component)_version)'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):${$(component)_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_$(component) $(docker_repo)/kopano_$(component):latest
	git commit -m 'ci: committing changes for $(component)' -- $(component)
	git tag $(component)/${$(component)_version} || true

tag-base:
	component=base make tag

tag-core:
	component=core make tag

tag-webapp:
	component=webapp make tag

# Docker publish
repo-login:
	docker login -u $(docker_login) -p $(docker_pwd)

publish: repo-login publish-base publish-core publish-webapp
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
