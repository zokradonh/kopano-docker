docker_repo := zokradonh
docker_login := `cat ~/.docker-account-user`
docker_pwd := `cat ~/.docker-account-pwd`

base_version = $(shell docker run --rm $(docker_repo)/kopano_base cat /kopano/buildversion)
core_version = $(shell docker run --rm $(docker_repo)/kopano_core cat /kopano/buildversion | grep -o -P '(?<=-).*(?=_)')
webapp_version = $(shell docker run --rm $(docker_repo)/kopano_webapp cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)')

build-all: build-base build-core build-webapp

build: component ?= base
build:
	docker build -t $(docker_repo)/kopano_$(component) $(component)/

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
	git tag $(component)/${$(component)_version} || true

tag-base:
	component=base make tag

tag-core:
	component=core make tag

tag-webapp:
	component=webapp make tag

git-commit:
	git add -A && git commit -m "ci: commit changes before tagging"

# Docker publish
repo-login:
	docker login -u $(docker_login) -p $(docker_pwd)

publish: git-commit repo-login publish-base publish-core publish-webapp
	git push
	git push origin --tags

publish-base: build-base tag-base
	@echo 'publish latest to $(docker_repo)/kopano_base'
	docker push $(docker_repo)/kopano_base:${base_version}
	docker push $(docker_repo)/kopano_base:latest

publish-core: build-core tag-core
	@echo 'publish latest to $(docker_repo)/kopano_core'
	docker push $(docker_repo)/kopano_core:${core_version}
	docker push $(docker_repo)/kopano_core:latest

publish-webapp: build-webapp tag-webapp
	@echo 'publish latest to $(docker_repo)/kopano_webapp'
	docker push $(docker_repo)/kopano_webapp:${webapp_version}
	docker push $(docker_repo)/kopano_webapp:latest
