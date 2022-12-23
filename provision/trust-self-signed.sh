#!/bin/bash

# server cert
sudo mkdir -p /usr/share/ca-certificates/server/
sudo cp /vagrant/helloworld/greeter_server/ca-cert.pem /usr/share/ca-certificates/server/
echo "server/ca-cert.pem" | sudo tee -a /etc/ca-certificates.conf
# proxy cert
sudo mkdir -p /usr/share/ca-certificates/proxy/
sudo cp /vagrant/nginx/ca-cert.pem /usr/share/ca-certificates/proxy/
echo "proxy/ca-cert.pem" | sudo tee -a /etc/ca-certificates.conf
sudo update-ca-certificates