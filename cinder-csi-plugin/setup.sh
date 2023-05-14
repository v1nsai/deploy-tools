#!/bin/bash

set -e
kubectl delete sc cinder-default || true
# Create secret
kubectl create secret -n kube-system generic cloud-config --from-file=auth/cloud.conf || true

# Deploy controller manager roles with secret
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml

# Deploy Cinder
# helm repo add cpo https://kubernetes.github.io/cloud-provider-openstack
# helm repo update
# helm install cinder-csi cpo/openstack-cinder-csi -f helm/cloud-provider-cinder-values.yaml

# Deploy the CSI Cinder controller plugin
# git clone https://github.com/kubernetes/cloud-provider-openstack
# cd cloud-provider-openstack
# git checkout tags/v1.23.4
# rm manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
# update cacerts lines here TODO automate this
kubectl -f cinder-csi-plugin/manifests/ apply
