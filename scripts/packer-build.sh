#!/bin/bash

set -e
export PACKER_LOG=1
export PACKER_LOG_PATH=packer.log

echo "Deleting old image and instance if found..."
openstack server delete $1 || echo "Server not found, skipping delete"
scripts/remove-images.sh $1 || echo "Image not found, skipping delete"
if [[ ! -z "$2" ]]; then
    scripts/remove-images.sh $2 || echo "Image not found, skipping delete"
fi

echo "Building new image..."
packer init -upgrade projects/$1/packer
packer fmt projects/$1/packer
packer validate projects/$1/packer
packer build projects/$1/packer
