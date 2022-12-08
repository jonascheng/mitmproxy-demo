.DEFAULT_GOAL := help

.PHONY: setup
setup:	## setup go modules
	cd helloworld/proto/helloworld && protoc --go_out=:. --go-grpc_out=. helloworld.proto
	cd helloworld/greeter_server && go mod tidy
	cd helloworld/greeter_client && go mod tidy

.PHONY: run-greeter-server
run-greeter-server: setup	## runs go run the application
	cd helloworld/greeter_server && go run main.go

.PHONY: run-greeter-client
run-greeter-client: setup	## runs go run the application
	cd helloworld/greeter_client && go run main.go

.PHONY: start-mitmproxy
start-mitmproxy:	## start mitmproxy, and listen on port 8080
	docker run --rm -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy -p 8080:8080 mitmproxy/mitmproxy
