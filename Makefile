.PHONY: build build-mycoind build-tendermint tools key setup deploy

OPS := $(shell pwd)
TM_VERSION := v0.17.1
WEAVE_VERSION := master
TF_VERSION := 0.11.5

# build creates the tendermint and mycoind binaries for linux
build: build-mycoind build-tendermint

# build mycoind and place in ./bin
build-mycoind:
	go get -u -d github.com/confio/weave
	cd $$GOPATH/src/github.com/confio/weave && \
		git checkout $(WEAVE_VERSION) && glide install
	cd $$GOPATH/src/github.com/confio/weave/examples/mycoind && \
		BUILDOUT=$(OPS)/bin/mycoind make build

build-tendermint:
	go get github.com/golang/dep/cmd/dep
	go get -u -d github.com/tendermint/tendermint || true
	cd $$GOPATH/src/github.com/tendermint/tendermint && \
		git checkout $(TM_VERSION) && \
		make ensure_deps && make build && \
		cp ./build/tendermint $(OPS)/bin/tendermint

tools:
	# setup terraform
	@ curl https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_linux_amd64.zip > terraform.zip
	sudo unzip terraform.zip terraform -d /usr/local/bin
	@ rm terraform.zip
	# set up aws cli (assume you have virtualenv-wrapper installed)
	@ mkvirtualenv aws
	@ pip install awscli

key:
	aws ec2 create-key-pair --key-name terraform | jq -r .KeyMaterial > ~/.ssh/terraform.pem
	chmod 400 ~/.ssh/terraform.pem
	ssh-add ~/.ssh/terraform.pem

setup:
	cd terraform && terraform init

deploy:
	cd terraform && terraform apply
