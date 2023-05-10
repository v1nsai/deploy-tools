#!/bin/bash

set -e
source auth/wordpress.env

# Create application credential and use it to create a kubernetes secret
openstack application credential create techig-wordpress
# TODO grab ID and secret after creating them
kubectl create secret generic wordpress-auth \
    --from-file=wordpress/cloud.conf \
    --from-literal=wordpress-password="$WORDPRESS_PASSWORD"

helm install -f wordpress/values.yaml techig-wordpress oci://registry-1.docker.io/bitnamicharts/wordpress \
    --set "mariadb.auth.rootPassword=$MARIADB_PASSWORD,mariadb.auth.password=$MARIADB_PASSWORD"