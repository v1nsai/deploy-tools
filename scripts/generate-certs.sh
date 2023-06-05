#!/bin/bash

set -e
mkdir -p auth/$1
cd auth/$1
SERVER_NAME="$1"

# # Initialize Easy-RSA
easyrsa init-pki

# # Generate a new CA
easyrsa --batch build-ca nopass

# Generate a server key and signing request
easyrsa --batch build-server-full $SERVER_NAME nopass

# Generate the server certificate
cp pki/private/$SERVER_NAME.key pki/issued/$SERVER_NAME.crt

# Sign the server certificate using the CA
easyrsa --batch sign-req server $SERVER_NAME

mv pki/ca.crt pki/techig-ca.crt
cd $(git rev-parse --show-toplevel)