VERSION := $(shell git describe --tags 2> /dev/null || echo no-tag)
BRANCH := $(shell git symbolic-ref -q --short HEAD)
COMMIT := $(shell git rev-parse HEAD)

export PROJECT_DIR := ${PR_DIR}
ifndef PROJECT_DIR
override PROJECT_DIR = mocker
endif

# Use linker flags to provide version/build settings
# https://stackoverflow.com/questions/47509272/how-to-set-package-variable-using-ldflags-x-in-golang-build
LDFLAGS := -ldflags "-X $(PROJECT_DIR)/internal/ver.version=$(VERSION) -X $(PROJECT_DIR)/internal/ver.commit=$(COMMIT) -X $(PROJECT_DIR)/internal/ver.branch=$(BRANCH) -X $(PROJECT_DIR)/internal/ver.buildTime=`date '+%Y-%m-%d_%H:%M:%S_%Z'`'"

export GO_BIN := $(GGDEB_BIN_NAME)

# Default value for params
ifndef GO_BIN
override GO_BIN = "mocker"
endif

APP = $(LDFLAGS) main.go

print:
	$(info version: $(VERSION) branch: $(BRANCH) commit: $(COMMIT) LDFLAGS: $(LDFLAGS))

up:
	docker-compose up --build

all: help
help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: prepare ## Build app
	@go build -o $(GO_BIN) $(APP)

prepare: #swagger ##protogen ## Prepare for build

swagger: ## Swagger models generate
	@rm -rf client
	@rm -rf restapi/operations restapi/doc.go restapi/embedded_spec.go restapi/server.go
	@swagger generate server --exclude-main -f "./api/swagger.yaml"
	@swagger generate client -f api/swagger.yaml -c client/send_api -m client/send_models

protogen:
	@rm -rf proto
	@mkdir proto
	@protoc message.proto -I${GOPATH}/pkg/mod/ -I${GOPATH}/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.14.6/third_party/googleapis --go_out=plugins=grpc:proto/ --proto_path=api --go_opt=paths=source_relative

soapgen:
	@rm -rf myproxy
	@mkdir myproxy
	@protoc message.proto -I${GOPATH}/pkg/mod/ -I${GOPATH}/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.14.6/third_party/googleapis --wsdl_out=myproxy:myproxy --proto_path=api
	@protoc message.proto -I${GOPATH}/pkg/mod/ -I${GOPATH}/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.14.6/third_party/googleapis --grpcer_out=myproxy:myproxy --proto_path=api
	@protoc message.proto -I${GOPATH}/pkg/mod/ -I${GOPATH}/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.14.6/third_party/googleapis --grpc-gateway_out=proto --proto_path=api

mock:
	@rm -rf mocks/mock_callback_handler.go mocks/mock_event_listener_collector.go
	@mockgen -destination=mocks/mock_callback_handler.go -package=mocks integration_http/internal/controllers ICallbackHandler
	@mockgen -destination=mocks/mock_event_listener_collector.go -package=mocks integration_http/internal/services/listener IEventListenerStat

# awk не получилось заставить работать
docker-image:
	$(eval IMAGE_ID=`docker build -f ./docker/Dockerfile . | awk '/Successfully built/ {print $$3}'`)
	@echo $(IMAGE_ID) | cut -c 20-

download:
	@GOPRIVATE=stash.prostream.ru go mod download

unit-tests: mocks
	@go test ./...
#
#    echo Image is $$IMAGE_ID

#test-all: build test-lint test-unit test-blackbox ## Run all tests
#test-unit: ## Run unit tests
#	@./app seed_db -c="config/config_test.yaml"
#	@go clean -testcache ./internal/... && go test -count 1 -parallel 1 -cover -coverprofile=cover.out ./internal/...
#
#test-lint: ## Run golangci linter
#	@golangci-lint run ./internal/...
#
#test-blackbox: ## Run blackbox
#	@./app seed_db -c="config/config_test.yaml"
#	@sed 's/2000/2010/g' ./test/postman.json > ./test/postman_test.json
#	@./app http -c="./config/config_test.yaml" 2> /dev/null &
#	@sleep 1 && newman run test/postman_test.json
#	@kill `lsof -t -i:2010`
#	@rm ./test/postman_test.json
#
#test-open-coverage: ## Open coverage from run last unit test
#	@go tool cover -html=cover.out
