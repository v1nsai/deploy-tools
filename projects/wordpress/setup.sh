#!/bin/bash

set -e
source auth/wordpress/wordpress.env

# Create application credential and use it to create a kubernetes secret
# openstack application credential create techig-wordpress
# TODO grab ID and secret after creating them
# kubectl create secret generic wordpress-auth \
#     --from-file=auth/cloud.conf \
#     --from-literal=wordpress-password="$WORDPRESS_PASSWORD" || true

# Create a secret for the certs and keys
# python wordpress/certs2secret.yaml
# kubectl apply -f wordpress/tls-secret.yaml

# Install the helm chart
helm install -f wordpress/values.yaml wordpress oci://registry-1.docker.io/bitnamicharts/wordpress