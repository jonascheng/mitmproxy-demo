#!/bin/bash

wget -O /tmp/go1.19.3.linux-amd64.tar.gz https://go.dev/dl/go1.19.3.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf /tmp/go1.19.3.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile