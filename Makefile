.DEFAULT_GOAL := help

.PHONY: setup
setup: ## setup go modules
	cd helloworld/helloworld && protoc --go_out=:. --go-grpc_out=. helloworld.proto
	cd helloworld/greeter_server && go mod tidy
	cd helloworld/greeter_client && go mod tidy

.PHONY: start-mitmproxy
start-mitmproxy:	## start mitmproxy, and listen on port 8080
	docker run --rm -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy -p 8080:8080 mitmproxy/mitmproxy
