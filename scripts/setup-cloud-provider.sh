#!/bin/bash

# Create secret
kubectl create secret -n kube-system generic cloud-config --from-file=auth/cloud.conf

# Deploy provider
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml

# Deploy the CSI Cinder controller plugin
git clone https://github.com/kubernetes/cloud-provider-openstack
cd cloud-provider-openstack
git checkout tags/v1.23.4
rm manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
# update cacerts lines here TODO
kubectl -f manifests/cinder-csi-plugin/ apply
