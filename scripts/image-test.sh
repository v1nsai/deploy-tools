#!/bin/bash

set -e

echo "Deleting old image and uploading new image..."
openstack image delete $1 || echo "Image not found, skipping delete"
openstack image create \
    --disk-format qcow2 \
    --file output-$1/$1 \
    --progress \
    $1

echo "Deleting and recreating new instance..."
openstack server delete $1 || echo "Instance not found, skipping delete"
openstack server create \
  --flavor alt.c2.medium \
  --image $1 \
  --network $1 \
  --security-group default \
  --security-group ssh-ingress \
  --key-name $1 \
  $1 \
  --wait
openstack port create --network wordpress --device wordpress wordpress-port
openstack server add floating ip $1 "216.87.32.215"

echo "Connecting to instance..."
scripts/ssh-servername.sh $1
