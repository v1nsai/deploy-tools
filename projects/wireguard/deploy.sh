#!/bin/bash

set -e
source auth/alterncloud.env

# Clone repo if necessary
git clone https://github.com/trailofbits/algo.git projects/wireguard/algo || true
cp -f projects/wireguard/config.cfg projects/wireguard/algo/config.cfg
cp -f projects/wireguard/main.yml projects/wireguard/algo/roles/cloud-openstack/tasks/main.yml

# Configure environment, openstacksdk needs to be manually downgraded which requires python < 3.11, 3.9 confirmed working
python3 -m pip install --user --upgrade virtualenv
python3 -m virtualenv --python="$(command -v python3)" projects/wireguard/algo/.env || true &&
  source projects/wireguard/algo/.env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r projects/wireguard/requirements.txt

# # Run the playbook
ansible-playbook projects/wireguard/algo/main.yml -e "provider=openstack
                                                        server_name=wireguard
                                                        ondemand_cellular=false
                                                        ondemand_wifi=false
                                                        dns_adblocking=true
                                                        ssh_tunneling=false
                                                        store_pki=true"
# scripts/apply-terraform.sh projects/wireguard

# TODO figure out how to change 3155/dnscrypt-proxy on the deployed server after switching the interface to run wireguard on