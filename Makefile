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

.PHONY: setup-server-key
setup-server-key: ## generate grpc server cert
	cd helloworld/greeter_server && SITE_NAME=10.1.0.10 /vagrant/provision/cert-gen.sh

.PHONY: run-greeter-server
run-greeter-server: setup	## runs go run the application
	cd helloworld/greeter_server && go run main.go

.PHONY: setup-ngx-key
setup-ngx-key: ## generate nginx server cert
	cd /vagrant/nginx/ && SITE_NAME=10.1.0.30 /vagrant/provision/cert-gen.sh
	provision/trust-self-signed.sh

.PHONY: run-ngxproxy
run-ngxproxy:	## run nginx proxy, and listen on port 8080 (http) & 8081 (grpc)
	docker run --rm -it -v /vagrant/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -v /vagrant/nginx/:/tmp/:ro -p 8080:8080 -p 8081:8081 nginx:alpine-slim

.PHONY: run-squidproxy
run-squidproxy:	## run squid proxy, and listen on port 8080 (http)
	docker run --rm -it -p 8080:3128 docker.io/salrashid123/squidproxy /apps/squid/sbin/squid -NsY -f /apps/squid.conf.forward

.PHONY: run-greeter-grpc-client
run-greeter-grpc-client: setup	## runs go run the application to issue grpc request
	grpcurl -import-path helloworld/proto/ -proto helloworld.proto -d '{"name": "grpc"}' 10.1.0.10:8081 helloworld.Greeter/SayHello

.PHONY: run-greeter-grpc-client-via-proxy
run-greeter-grpc-client-via-proxy: setup	## runs go run the application to issue grpc request
	HTTPS_PROXY=http://10.1.0.30:8080 \
	grpcurl -import-path helloworld/proto/ -proto helloworld.proto -d '{"name": "grpc"}' 10.1.0.10:8081 helloworld.Greeter/SayHello

.PHONY: run-greeter-http-client
run-greeter-http-client: ## runs go run the application to issue http request
	curl -X POST -k https://10.1.0.10:8080/v1/echo -d '{"name": "http"}' | python -m json.tool

.PHONY: run-greeter-http-client-via-proxy
run-greeter-http-client-via-proxy: ## runs go run the application to issue http request
	http_proxy="10.1.0.30:8080" \
	https_proxy="10.1.0.30:8080" \
	curl -X POST -k https://10.1.0.10:8080/v1/echo -d '{"name": "http-proxy"}' | python -m json.tool

.PHONY: run-mitmproxy
run-mitmproxy:	## run mitmproxy, and listen on port 8080
	docker run --rm -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy -p 8080:8080 mitmproxy/mitmproxy

.PHONY: setup-client-ca
setup-client-ca: ## trust self signed cert
	provision/trust-self-signed.sh

.PHONY: help
help: ## prints this help message
	@echo "Usage: \n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'