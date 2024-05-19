#!/bin/bash

set -e
source auth/openstack.env

sudo apt update
sudo apt install -y wget vim python3 python3-pip whois nnn net-utils dnsutils
sudo ln -s /usr/bin/python3 /usr/bin/python || echo "Python symlink already exists, skipping..."

# kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# rm ./kubectl

# helm
# curl -fsSL -o "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" | bash -x

# kompose
# curl -L https://github.com/kubernetes/kompose/releases/download/v1.31.2/kompose-linux-arm64 -o kompose
# chmod +x kompose
# sudo mv ./kompose /usr/local/bin/kompose

# terraform and packer
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform packer

# openstack clients and python packages
python -m pip install --user ansible python-openstackclient python-neutronclient python-octaviaclient python-heatclient python-magnumclient virtualenv

# yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq

#cleanup
# echo "source auth/openstack.env" >> ~/.profile
# sudo chmod 666 /run/host-services/ssh-auth.sock # ssh agent forwarding
source ~/.bashrc
terraform -install-autocomplete

