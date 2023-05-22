#!/bin/bash
set -e 

# Create the cluster
terraform -chdir=projects/wordpress init
terraform -chdir=projects/wordpress apply -var-file ../../auth/auth.tfvars -auto-approve
rm projects/wordpress/.kube/config || true
openstack coe cluster config wordpress --dir projects/wordpress/.kube/ --use-certificate

# Create application credential and use it to create a kubernetes secret
# openstack application credential create techig-wordpress
# TODO grab ID and secret after creating them
kubectl create secret generic wordpress-auth \
    --from-file=auth/cloud.conf \
    --from-literal=wordpress-password="$WORDPRESS_PASSWORD" || true

# # Generate the signed cert and ca
# scripts/generate-signed-cert.sh

# # Add auth/wordpress/key-bundle.pem and cert-bundle.pem to the wordpress secret
kubectl delete secret wp-tls-secret || true
kubectl create secret generic wp-tls-secret \
    --from-file=auth/wordpress/key-bundle.pem \
    --from-file=auth/wordpress/cert-bundle.pem

# setup cinder
../cinder-csi-plugin/deploy.sh

# setup cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# Install the helm chart
helm install -f projects/wordpress/values.yaml wordpress oci://registry-1.docker.io/bitnamicharts/wordpress