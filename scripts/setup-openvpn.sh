#!/bin/bash

set -e

echo "Creating CA..."
apt update
apt install -y easy-rsa openvpn
mkdir /home/drew/easy-rsa
ln -s /usr/share/easy-rsa/* /home/drew/easy-rsa/
chmod 700 /home/drew/easy-rsa
cd /home/drew/easy-rsa
./easyrsa init-pki
cat <<EOF > vars
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "NewYork"
set_var EASYRSA_REQ_CITY       "New York City"
set_var EASYRSA_REQ_ORG        "TechIG"
set_var EASYRSA_REQ_EMAIL      "ariffle@techig.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
EOF
./easyrsa build-ca nopass

echo "Signing cert and creating private key..."
./easyrsa gen-req server nopass
mkdir -p /etc/openvpn/server
cp /home/drew/easy-rsa/pki/private/server.key /etc/openvpn/server/
# ./easyrsa import-req pki/reqs/server.req server
./easyrsa sign-req server server
cp pki/issued/server.crt /etc/openvpn/server
cp pki/ca.crt /etc/openvpn/server

echo "Configuring tls-crypt and user key..."
openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/server
mkdir -p /home/drew/client-configs/keys
chmod -R 700 /home/drew/client-configs
./easyrsa gen-req client1 nopass
cp pki/private/client1.key /home/drew/client-configs/keys/
