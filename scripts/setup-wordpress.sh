#!/bin/bash

set -e

openstack application credential create techig-wordpress
# TODO grab ID and secret after creating them
kubectl create secret generic wordpress-auth \
    --from-file=auth/techig-wordpress-cloud.conf \
    --from-literal=wordpress-password='jonk9ym.;lkj;lkj'

helm install -f helm/wordpress-values.yaml techig-wordpress oci://registry-1.docker.io/bitnamicharts/wordpress