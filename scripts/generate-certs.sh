#!/bin/bash

set -e
# Variables
SERVER_DIR="/etc/ssl/private"
CA_DIR="/etc/ssl/certs"
SERVER_NAME="server"

# Cleanup before recreating
rm -rf $SERVER_DIR
mkdir -p $SERVER_DIR

# Create CA
cd $CA_DIR
/usr/share/easy-rsa/easyrsa init-pki
/usr/share/easy-rsa/easyrsa build-ca nopass


# Generate server certificate and key
cd $SERVER_DIR
/usr/share/easy-rsa/easyrsa init-pki
/usr/share/easy-rsa/easyrsa gen-req $SERVER_NAME nopass
/usr/share/easy-rsa/easyrsa sign-req server $SERVER_NAME

cd 
echo "Generated certs and added them to $1"