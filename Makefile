.PHONY: build build-mycoind build-tendermint

OPS := $(shell pwd)
TM_VERSION := v0.17.1
WEAVE_VERSION := master

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

