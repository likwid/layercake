platform := $(shell uname)

install: install-third-party-tools

ifeq (${platform},Darwin)
install-third-party-tools:
	brew install packer terraform nodejs
	npm install -g yaml-cli
else
install-third-party-tools:
	@echo "${platform} is a platform we have no presets for, you'll have to install the third party dependencies manually (packer, terraform, nodejs, yaml-cli (via npm)"
endif

validate-trusty:
	@yaml json write tools/packer/base/trusty.yml | packer validate -

build-trusty: validate-trusty
	@yaml json write tools/packer/base/trusty.yml | packer build -

test:
	@bash scripts/test.sh

.PHONY: install-third-party-tools build-trusty validate-trusty test
