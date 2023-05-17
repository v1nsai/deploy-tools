#!/bin/bash

set -e

# Create a Certificate Authority (CA)
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -days 3650 -subj "/C=US/ST=CA/L=San Francisco/O=My Company, Inc./CN=My Company CA"

# Create a certificate and private key
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=CA/L=San Francisco/O=My Company, Inc./CN=example.com"

# Use the CA to sign the certificate
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365

# Clean up the CSR and serial files
rm server.csr ca.srl

# Bundle the CA certificate and key into a single file
cat ca.crt ca.key > ca-bundle.pem

# Bundle the server certificate and key into a single file
cat server.crt server.key > server-bundle.pem

# Bundle keys and certs
cat ca.crt server.crt > cert-bundle.pem
cat ca.key server.key > key-bundle.pem

# Move to auth
mv -f *.pem auth/
mv -f *.crt auth/
mv -f *.key auth/