#!/bin/bash

sudo apt-get update && sudo apt-get install -y wget

# wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.0/grpcurl_1.8.0_linux_x86_64.tar.gz
wget https://github.com/L11R/grpcurl/releases/download/v1.8.8/grpcurl_1.8.8_linux_x86_64.tar.gz

tar -zxvf grpcurl_1.8.8_linux_x86_64.tar.gz

sudo mv grpcurl /usr/bin/grpcurl
