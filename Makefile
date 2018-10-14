docker_repo := zokradonh
docker_login := `cat ~/.docker-account-user`
docker_pwd := `cat ~/.docker-account-pwd`

# TODO get actual version from container, below fails since it runs through dumb-init
base_version = $(shell docker run --rm $(docker_repo)/kopano_base cat /kopano/buildversion)
core_version = $(shell docker run --rm $(docker_repo)/kopano_core cat /kopano/buildversion | grep -o -P '(?<=-).*(?=_)')
webapp_version = $(shell docker run --rm $(docker_repo)/kopano_webapp cat /kopano/buildversion | tail -n 1 | grep -o -P '(?<=-).*(?=\+)')

build-all: build-base build-core build-webapp

build-base:
	docker build -t $(docker_repo)/kopano_base base/

tag-base:
	@echo 'create tag $(base_version)'
	docker tag $(docker_repo)/kopano_base $(docker_repo)/kopano_base:${base_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_base $(docker_repo)/kopano_base:latest
	git tag base/${base_version} || true

build-core: build-base
	docker build -t $(docker_repo)/kopano_core  core/

tag-core:
	@echo 'create tag $(core_version)'
	docker tag $(docker_repo)/kopano_core $(docker_repo)/kopano_core:${core_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_core $(docker_repo)/kopano_core:latest
	git tag core/${core_version} || true

build-webapp: build-base
	docker build -t $(docker_repo)/kopano_webapp  webapp/

tag-webapp:
	@echo 'create tag $(webapp_version)'
	docker tag $(docker_repo)/kopano_webapp $(docker_repo)/kopano_webapp:${webapp_version}
	@echo 'create tag latest'
	docker tag $(docker_repo)/kopano_webapp $(docker_repo)/kopano_webapp:latest
	git tag webapp/${webapp_version} || true

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
