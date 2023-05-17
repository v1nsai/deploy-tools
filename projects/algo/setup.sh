#!/bin/bash

set -e
source auth/alterncloud.env

# Clone repo if necessary, remove generated configs and copy server configs
# git clone https://github.com/trailofbits/algo.git ../algo
cp -f algo/config.cfg ../algo/config.cfg
cp -f algo/requirements.txt ../algo/requirements.txt
rm -rf algo/configs || true

# Configure environment, openstacksdk needs to be manually downgraded which requires python < 3.11, 3.9 confirmed working
python3 -m pip install --user --upgrade virtualenv
python3 -m virtualenv --python="$(command -v python3)" ../algo/env &&
  source ../algo/.env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r algo/requirements.txt

# Run the playbook
ansible-playbook ../algo/main.yml -e "provider=openstack
                                        server_name=wireguard
                                        ondemand_cellular=false
                                        ondemand_wifi=false
                                        dns_adblocking=true
                                        ssh_tunneling=false
                                        store_pki=true"

# Cleanup
deactivate
rm -rf algo/configs/
cp -rf ../algo/configs/ algo/
