#!/bin/bash

set -e

# echo "Deleting old image and uploading new image..."
# openstack image delete $1 || echo "Image not found, skipping delete"
# openstack image create \
#     --disk-format qcow2 \
#     --container-format bare \
#     --min-disk 10 \
#     --file $2 \
#     --progress \
#     $1

echo "Deleting and recreating new instance..."
openstack server delete $1 || echo "Instance not found, skipping delete"
openstack server create \
  --flavor alt.c2.medium \
  --image $1 \
  --network $1 \
  --ephemeral size=10 \
  --security-group default \
  --security-group ssh-ingress \
  --key-name $1 \
  $1 \
  --wait
openstack server add floating ip $1 "216.87.32.215"

echo "Connecting to instance..."
scripts/ssh-servername.sh $1