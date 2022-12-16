.DEFAULT_GOAL := help

.PHONY: setup
setup:	## setup go modules
	cd helloworld/ && protoc -I ./proto \
		--go_out ./proto --go_opt paths=source_relative \
		--go-grpc_out ./proto  --go-grpc_opt paths=source_relative \
		--grpc-gateway_out ./proto  --grpc-gateway_opt paths=source_relative \
		./proto/helloworld.proto
	cd helloworld/greeter_server && go mod tidy
	cd helloworld/greeter_client && go mod tidy

.PHONY: run-greeter-server
run-greeter-server: setup	## runs go run the application
	cd helloworld/greeter_server && go run main.go

.PHONY: run-greeter-grpc-client
run-greeter-grpc-client: setup	## runs go run the application to issue grpc request
	cd helloworld/greeter_client && go run main.go

.PHONY: run-greeter-http-client
run-greeter-http-client: ## runs go run the application to issue http request
	curl -X POST -k http://10.1.0.10:8080/v1/echo -d '{"name": "http"}'

.PHONY: run-greeter-http-client-via-proxy
run-greeter-http-client-via-proxy: ## runs go run the application to issue http request
	curl --proxy http://10.1.0.30:8080/ -X POST -k http://10.1.0.10:8080/v1/echo -d '{"name": "http-proxy"}'

.PHONY: run-mitmproxy
run-mitmproxy:	## run mitmproxy, and listen on port 8080
	docker run --rm -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy -p 8080:8080 mitmproxy/mitmproxy

.PHONY: run-ngxproxy
run-ngxproxy:	## run nginx proxy, and listen on port 8080
	docker run --rm -it -v /vagrant/nginx/nginx_whitelist.conf:/usr/local/nginx/conf/nginx.conf -p 8080:8080 reiz/nginx_proxy:0.0.3

.PHONY: help
help: ## prints this help message
	@echo "Usage: \n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'