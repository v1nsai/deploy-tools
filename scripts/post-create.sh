#!/bin/bash

set -e
source auth/alterncloud.env

# sudo apt update
# sudo apt install -y wget

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform vim

# helm
curl -fsSL -o https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -x

# openstack clients and python packages
python -m pip install --user -r projects/wireguard/requirements.txt 
python -m pip install --user ansible==6.1.0 python-openstackclient python-neutronclient python-octaviaclient python-heatclient python-magnumclient

echo "source /workspaces/deploy-tools/auth/alterncloud.env" >> ~/.bashrc
source ~/.bashrc
terraform -install-autocomplete

# kubectl
# sudo apt-get update
# sudo apt-get install -y ca-certificates curl apt-transport-https
# sudo mkdir /etc/apt/keyrings || true
# sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# echo 'source <(kubectl completion bash)' >>~/.bashrc
# kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
# sudo chmod a+r /etc/bash_completion.d/kubectl

# # helm
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo -E bash -x -

# # terraform
# sudo apt-get install -y gnupg software-properties-common
# wget -O- https://apt.releases.hashicorp.com/gpg | \
# gpg --dearmor | \
# sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
# wget -O- https://apt.releases.hashicorp.com/gpg | \
# gpg --dearmor | \
# sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
# gpg --no-default-keyring \
# --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
# --fingerprint
# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
# https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
# sudo tee /etc/apt/sources.list.d/hashicorp.list