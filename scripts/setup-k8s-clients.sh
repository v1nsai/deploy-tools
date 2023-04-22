#!/bin/bash

# Install k8s clients
echo "Installing k8s clients..."
snap install kubectl --classic
snap install helm --classic

# Config 
source /home/drew/auth/alterncloud.env
mkdir /home/drew/.kube
# openstack coe cluster config wordpress --dir /home/drew/.kube/ --use-certificate

# TODO remove this
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm install techig bitnami/wordpress
