#!/bin/bash
# Ref: https://dev.to/techschoolguru/how-to-create-sign-ssl-tls-certificates-2aai
#

rm *.pem

# 1. Generate CA's private key and self-signed certificate
openssl req -x509 -newkey rsa:4096 -days 90 -nodes \
    -keyout ca-key.pem \
    -out ca-cert.pem \
    -subj "/CN=$SITE_NAME/O=TXOne Networks/OU=R&D/C=TW/ST=Taipei/L=Taipei"

echo "CA's self-signed certificate"
openssl x509 -in ca-cert.pem -noout -text

# 2. Generate web server's private key and certificate signing request (CSR)
openssl req -newkey rsa:4096 -nodes \
    -keyout server-key.pem \
    -out server-req.pem \
    -subj "/CN=$SITE_NAME/O=TXOne Networks/OU=R&D/C=TW/ST=Taipei/L=Taipei"

# 3. Use CA's private key to sign web server's CSR and get back the signed certificate
openssl x509 -req -days 60 \
    -in server-req.pem \
    -CA ca-cert.pem \
    -CAkey ca-key.pem \
    -CAcreateserial \
    -out server-cert.pem \
    -extfile server-ext.cnf

echo "Server's signed certificate"
openssl x509 -in server-cert.pem -noout -text
