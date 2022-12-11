#!/bin/bash

# install protoc
PB_REL="https://github.com/protocolbuffers/protobuf/releases"
wget -O /tmp/protoc-21.11-linux-x86_64.zip $PB_REL/download/v21.11/protoc-21.11-linux-x86_64.zip
unzip /tmp/protoc-21.11-linux-x86_64.zip -d /tmp
sudo cp /tmp/bin/protoc /usr/bin/protoc

# install go plugins for the protocol compiler
/usr/local/go/bin/go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
/usr/local/go/bin/go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
/usr/local/go/bin/go install \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest

# install grpcurl tool
/usr/local/go/bin/go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
# update PATH so that the protoc compiler can find the plugins
echo "export PATH=\$PATH:$(/usr/local/go/bin/go env GOPATH)/bin" | sudo tee -a /etc/profile