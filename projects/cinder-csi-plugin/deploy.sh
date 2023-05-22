#!/bin/bash

set -e
kubectl delete sc cinder-default || true

# Create secret
kubectl delete secret -n kube-system cloud-config || true
# kubectl create -f manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
kubectl create secret -n kube-system generic cloud-config --from-file=$(envsubst < projects/cinder-csi-plugin/cloud.conf)

# Deploy the CSI Cinder controller plugin
git clone https://github.com/kubernetes/cloud-provider-openstack projects/cinder-csi-plugin/cloud-provider-openstack/ || true
git -C projects/cinder-csi-plugin/cloud-provider-openstack/ checkout tags/v1.23.4

rm projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml || true

# uncomment the volumes and volumeMounts in all the cinder-csi-plugin manifests with the name cacerts
sed -i 's/#- name: cacerts/- name: cacerts/g' projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/csi-controllerplugin.yaml
sed -i 's/#- name: cacerts/- name: cacerts/g' projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/csi-nodeplugin.yaml

# Deploy the CSI Cinder controller plugin
kubectl -f projects/cinder-csi-plugin/cloud-provider-openstack/manifests apply
kubectl -f projects/cinder-csi-plugin/storageclass.yaml apply

exit

# Cleanup before redeploying
kubectl delete secret -n kube-system cloud-config
kubectl -f projects/cinder-csi-plugin/manifests/ delete
kubectl -f projects/cinder-csi-plugin/storageclass.yaml delete
kubectl delete pv --all || true
kubectl delete pvc --all || true
