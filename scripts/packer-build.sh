#!/bin/bash

set -e
export PACKER_LOG=1
export PACKER_LOG_PATH=packer.log

echo "Deleting old image and instance..."
openstack server delete $1 || echo "Server not found, skipping delete"
openstack image delete $1 || echo "Image not found, skipping delete"

echo "Building new image..."
packer init -upgrade projects/$1/packer
packer fmt projects/$1/packer
packer validate projects/$1/packer
# echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
packer build projects/$1/packer
