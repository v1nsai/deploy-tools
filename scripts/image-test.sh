#!/bin/bash

set -e

echo "Building new image..."
openstack server delete $1 || echo "Server not found, skipping delete"
openstack image delete $1 || echo "Image not found, skipping delete"
scripts/packer-build.sh $1

echo "Deleting and recreating new instance..."
scripts/destroy-terraform.sh $1
scripts/apply-terraform.sh $1

echo "Switching to instance logs..."
scripts/watch-log.sh $1

echo "Connecting to instance..."
scripts/ssh-servername.sh $1
