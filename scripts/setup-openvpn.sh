#!/bin/bash

set -e

echo "Creating CA..."
apt install -y easy-rsa openvpn openssl
mkdir /home/drew/easy-rsa | true
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
mkdir -p /home/drew/client-configs/keys
cp /home/drew/easy-rsa/pki/issued/server.crt /etc/openvpn/server
cp /home/drew/easy-rsa/pki/ca.crt /etc/openvpn/server
cp /home/drew/easy-rsa/pki/ca.crt /home/drew/client-configs/keys/ca.crt

echo "Configuring tls-crypt and user key..."
openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/server/
cp ta.key /home/drew/client-configs/keys/
chmod -R 700 /home/drew/client-configs
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1
mkdir -p /home/drew/client-configs
cp /home/drew/easy-rsa/pki/private/client1.key /home/drew/client-configs/keys/
cp /home/drew/easy-rsa/pki/issued/client1.crt /home/drew/client-configs/keys/

echo "Configuring OpenVPN..."
# server.conf
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/
sed -i'' -e 's/\(tls-auth ta.key.*\)/;\1\ntls-crypt ta.key/' /etc/openvpn/server.conf
sed -i'' -e 's/\(cipher AES-256-CBC\)/;\1\ncipher AES-256-GCM\nauth SHA256/' /etc/openvpn/server.conf
sed -i'' -e 's/\(dh dh2048.pem\)/;\1\ndh none/' /etc/openvpn/server.conf
sed -i'' -e 's/;user nobody/user nobody/' /etc/openvpn/server.conf
sed -i'' -e 's/;user nobody/user nobody/' /etc/openvpn/server.conf
sed -i'' -e 's/;group nobody/group nobody/' /etc/openvpn/server.conf
sed -i'' -e 's/;\(push "redirect-gateway def1 bypass-dhcp"\)/\1/' /etc/openvpn/server.conf
sed -i'' -e 's/;\(push "dhcp-option DNS\).*/\1 1.1.1.1"\n\1 1.0.0.1"/' /etc/openvpn/server.conf
sed -i'' -e 's/port 1194/port 443/' /etc/openvpn/server.conf
sed -i'' -e 's/proto udp/proto tcp/' /etc/openvpn/server.conf
sed -i'' -e 's/explicit-exit-notify .*/explicit-exit-notify 0/' /etc/openvpn/server.conf

# sysctl.conf
sed -i'' -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# ufw TODO
# rules=$(cat <<EOF
# # START OPENVPN RULES
# # NAT table rules
# *nat
# :POSTROUTING ACCEPT [0:0]
# # Allow traffic from OpenVPN client to eth0 (change to the interface you discovered!)
# -A POSTROUTING -s 10.0.0.0/8 -o ens3 -j MASQUERADE
# COMMIT
# # END OPENVPN RULES
# EOF)
# sed -i'' -e 's/\#\s*ufw-before-forward.*?#/"'"$rules"'"/' /etc/ufw/before.rules

sed -i'' -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

ufw allow 443
ufw allow 80
ufw allow 1194
systemctl restart ufw

echo "Starting openvpn..."
systemctl -f enable --now openvpn-server@server.service

systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service

echo "Creating client config files..."
mkdir -p /home/drew/client-configs/files
cd /home/drew/
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /home/drew/client-configs/base.conf

# base.conf
sed -i'' -e 's/remote my-server-1 1194/remote 216.87.32.164 443/' /home/drew/client-configs/base.conf
sed -i'' -e 's/proto udp/proto tcp/' /home/drew/client-configs/base.conf
sed -i'' -e 's/;user nobody/user nobody/' /home/drew/client-configs/base.conf
sed -i'' -e 's/;group nobody/group nobody/' /home/drew/client-configs/base.conf
sed -i'' -e 's/ca ca.crt/;ca ca.crt/' /home/drew/client-configs/base.conf
sed -i'' -e 's/cert client.crt/;cert client.crt/' /home/drew/client-configs/base.conf
sed -i'' -e 's/key client.key/;key client.key/' /home/drew/client-configs/base.conf
sed -i'' -e 's/tls-auth ta.key 1/;tls-auth ta.key 1/' /home/drew/client-configs/base.conf
sed -i'' -e 's/cipher AES-256-CBC/cipher AES-256-GCM\nauth SHA256/' /home/drew/client-configs/base.conf
echo "key-direction 1" | tee -a /home/drew/client-configs/base.conf
resolvconf-config=$(cat <<EOF
; script-security 2
; up /etc/openvpn/update-resolv-conf
; down /etc/openvpn/update-resolv-conf
EOF)
systemdresolved-config=$(cat <<EOF
; script-security 2
; up /etc/openvpn/update-systemd-resolved
; down /etc/openvpn/update-systemd-resolved
; down-pre
; dhcp-option DOMAIN-ROUTE .
EOF)
sed -i'' -e 's///' /home/drew/client-configs/base.conf

cd /home/drew/client-configs/
./make_config.sh client1
 
# First argument: Client identifier
 
KEY_DIR=/home/drew/client-configs/keys
OUTPUT_DIR=/home/drew/client-configs/files
BASE_CONFIG=/home/drew/client-configs/base.conf
 
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/client1.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/client1.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/client1.ovpn