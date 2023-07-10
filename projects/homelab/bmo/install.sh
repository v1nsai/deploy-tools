#!/bin/bash

set -e

# adduser doctor_ew --disabled-password
# echo 'doctor_ew:;lkj;lkj' | chpasswd
# usermod -aG sudo doctor_ew
# echo "doctor_ew ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# # push the key up here
# sudo apt install -y docker docker-compose git wireguard resolvconf screen
# git clone git@github.com:v1nsai/deploy-tools.git
# cd deploy-tools
# scripts/docker-compose.sh plex & > /dev/null 2>&1
# scripts/docker-compose.sh deluge

# git config --global user.email "doctor_ew@protonmail.com"
# git config --global user.name "doctor_ew"

# aws configure import --csv file:///Users/doctor_ew/Downloads/doctor_ew_accessKeys.csv --profile homelab

wget https://downloads.plex.tv/plex-media-server-new/1.32.4.7195-7c8f9d3b6/debian/plexmediaserver_1.32.4.7195-7c8f9d3b6_amd64.deb
sudo dpkg -i plexmediaserver_1.32.4.7195-7c8f9d3b6_amd64.deb