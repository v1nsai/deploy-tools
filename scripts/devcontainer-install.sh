#!/bin/bash

set -e
source auth/alterncloud.env

# sudo apt update
# sudo apt install -y wget

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# kustomize
CURRENTDIR=$(pwd)
cd ~/.local/bin/
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
cd $CURRENTDIR

# terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform vim

# helm
curl -fsSL -o https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -x

# openstack clients and python packages
python -m pip install --user -r projects/wireguard/requirements.txt 
python -m pip install --user ansible==6.1.0 python-openstackclient python-neutronclient python-octaviaclient python-heatclient python-magnumclient

# yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq

#cleanup
echo "source /workspaces/deploy-tools/auth/alterncloud.env" >> ~/.profile
source ~/.profile
terraform -install-autocomplete