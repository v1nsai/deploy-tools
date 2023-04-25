#!/bin/bash

set -e

echo "Installing and configuring socks proxy..."
apt update
apt install -y dante-server
rm /etc/danted.conf || true

mv /home/drew/danted.conf /etc/danted.conf
systemctl restart danted