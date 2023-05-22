#!/bin/bash

set -e

# Cleanup before redeploying
kubectl -f projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/ delete || true
kubectl -f projects/cinder-csi-plugin/storageclass.yaml delete || true
kubectl delete sc cinder-default || true

# Create secret
kubectl delete secret -n kube-system cloud-config || true
# kubectl create -f manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
envsubst < projects/cinder-csi-plugin/cloud.conf > projects/cinder-csi-plugin/cloud.conf.subst
kubectl create secret -n kube-system generic cloud-config --from-file="projects/cinder-csi-plugin/cloud.conf.subst"

# Deploy the CSI Cinder controller plugin
git clone https://github.com/kubernetes/cloud-provider-openstack projects/cinder-csi-plugin/cloud-provider-openstack/ || true
git -C projects/cinder-csi-plugin/cloud-provider-openstack/ checkout tags/v1.23.4
rm projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml || true

# uncomment the volumes and volumeMounts in all the manifests at projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/ that have the name "cacerts"
sed -i 's/        # - name: cacert/        - name: cacert/g' projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/cinder-csi-controllerplugin.yaml
# TODO add the rest

# Deploy the CSI Cinder controller plugin
kubectl -f projects/cinder-csi-plugin/cloud-provider-openstack/manifests/cinder-csi-plugin/ apply
# kubectl -f projects/cinder-csi-plugin/storageclass.yaml apply

kubectl get pods -A -w
exit


kubectl delete pv --all || true
kubectl delete pvc --all || true
