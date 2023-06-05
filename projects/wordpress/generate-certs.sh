#!/bin/bash

set -e
# Variables
SERVER_DIR="/etc/ssl/private"
CA_DIR="/etc/ssl/certs"
SERVER_NAME="$1"
echo 1 > /tmp/progress
# Create CA
cd $CA_DIR
/usr/share/easy-rsa/easyrsa init-pki
/usr/share/easy-rsa/easyrsa build-ca nopass
echo 3 > /tmp/progress
# Generate server certificate and key
cd $SERVER_DIR
/usr/share/easy-rsa/easyrsa init-pki
/usr/share/easy-rsa/easyrsa build-ca nopass << EOF
your_common_name
EOF
echo 4 > /tmp/progress
cd 
echo "Generated certs and added them to $SERVER_NAME"