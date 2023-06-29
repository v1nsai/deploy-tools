#!/bin/bash

set -e

# echo "Deleting old image and uploading new image..."
# openstack image delete $1 || echo "Image not found, skipping delete"
# openstack image create \
#     --disk-format qcow2 \
#     --file output-$1/$1 \
#     --progress \
#     $1

echo "Deleting and recreating new instance..."
scripts/destroy-terraform.sh $1
scripts/apply-terraform.sh $1

echo "Switching to instance logs..."
scripts/watch-log.sh $1

echo "Connecting to instance..."
scripts/ssh-servername.sh $1
