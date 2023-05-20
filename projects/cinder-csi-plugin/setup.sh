#!/bin/bash

set -e
kubectl delete sc cinder-default || true

# Create secret
kubectl delete secret -n kube-system cloud-config || true
# kubectl create -f manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
kubectl create secret -n kube-system generic cloud-config --from-file=$(envsubst < projects/cinder-csi-plugin/)

# Deploy controller manager roles with secret
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml

# exit

# Deploy Cinder
# helm repo add cpo https://kubernetes.github.io/cloud-provider-openstack
# helm repo update
# helm install cinder-csi cpo/openstack-cinder-csi -f helm/cloud-provider-cinder-values.yaml

# Deploy the CSI Cinder controller plugin
# git clone https://github.com/kubernetes/cloud-provider-openstack ../cloud-provider-openstack || true
# git -C ../cloud-provider-openstack/ checkout tags/v1.23.4

# TODO figure out how to automate uncommenting lines for cacerts volumes in controllerplugin and nodeplugin 
kubectl -f projects/cinder-csi-plugin/manifests/ apply
kubectl -f projects/cinder-csi-plugin/storageclass.yaml apply

exit

# Cleanup before redeploying
kubectl delete secret -n kube-system cloud-config
kubectl -f projects/cinder-csi-plugin/manifests/ delete
kubectl -f projects/cinder-csi-plugin/storageclass.yaml delete
kubectl delete pv --all || true
kubectl delete pvc --all || true
