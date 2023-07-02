#!/bin/bash

set -e

adduser doctor_ew --disabled-password
echo 'doctor_ew:;lkj;lkj' | chpasswd
usermod -aG sudo doctor_ew
echo "doctor_ew ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# push the key up here
apt install -y docker docker-compose git wireguard
# git clone git@github.com:v1nsai/deploy-tools.git
cd deploy-tools
scripts/docker-compose.sh plex & > /dev/null 2>&1
scripts/docker-compose.sh deluge

git config --global user.email "doctor_ew@protonmail.com"
git config --global user.name "doctor_ew"