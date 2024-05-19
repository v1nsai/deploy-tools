#!/bin/bash

# set -e

echo "Getting all image IDs matching $1..."
image_ids=$(openstack image list -f json | jq -r '.[] | select(.Name == "'$1'") | .ID')

echo "Deleting images with IDs: $image_ids..."
if [[ $image_ids > 0 ]]; then
    openstack image delete $image_ids
else
    echo "No images found, skipping delete"
fi