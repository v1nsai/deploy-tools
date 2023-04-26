#!/bin/bash

# Install k8s clients
echo "Installing k8s clients..."
snap install kubectl --classic
snap install helm --classic

# Config 
source /etc/alterncloud.env
mkdir /etc/.kube
sleep 20
openstack coe cluster config wordpress --dir /etc/.kube/ --use-certificate
cp -r /etc/.kube/ /home/altern1/
cp -r /etc/.kube/ /home/altern2/

# Deployments
# TODO remove this
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm install techig bitnami/wordpress