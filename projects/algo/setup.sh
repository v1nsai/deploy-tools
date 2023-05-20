#!/bin/bash

set -e
source auth/alterncloud.env

# Clone repo if necessary, remove generated configs and copy server configs
# git clone https://github.com/trailofbits/algo.git ../algo
cp -f $2 ../algo/config.cfg
cp -f projects/algo/requirements.txt ../algo/requirements.txt
rm -rf projects/algo/configs || true

# Configure environment, openstacksdk needs to be manually downgraded which requires python < 3.11, 3.9 confirmed working
python3 -m pip install --user --upgrade virtualenv
python3 -m virtualenv --python="$(command -v python3)" ../algo/env &&
  source ../algo/.env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r projects/algo/requirements.txt

# Run the playbook
ansible-playbook ../algo/main.yml -e "provider=openstack
                                        server_name=$1
                                        ondemand_cellular=false
                                        ondemand_wifi=false
                                        dns_adblocking=true
                                        ssh_tunneling=false
                                        store_pki=true"

# Cleanup
deactivate
cp -rf ../algo/configs/ projects/algo/configs/

# TODO figure out how to change 3155/dnscrypt-proxy on the deployed server after switching the interface to run wireguard on