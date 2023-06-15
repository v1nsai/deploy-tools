#!/bin/bash

set -e

# Install dependencies
curl -sL https://roots.io/trellis/cli/get | sudo bash
python3 -m pip install virtualenv ansible
echo "export PATH=$PATH:/home/localadmin/.local/bin" >> /home/localadmin/.profile
ansible-galaxy install kwoodson.yedit
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq