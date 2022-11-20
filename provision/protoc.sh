#!/bin/bash

# install protoc
sudo apt update && sudo apt install -y protobuf-compiler

# install go plugins for the protocol compiler
/usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
/usr/local/go/bin/go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# install grpcurl tool
/usr/local/go/bin/go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
# update PATH so that the protoc compiler can find the plugins
echo "export PATH=\$PATH:$(/usr/local/go/bin/go env GOPATH)/bin" | sudo tee -a /etc/profile