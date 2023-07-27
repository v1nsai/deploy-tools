#!/bin/bash

set -e
source auth/alterncloud.env

if [[ ! -z "$2" ]] && [[ "$2" == '--buildimage' ]]; then
    echo "Building new image..."
    scripts/packer-build.sh $1
fi

echo "Deleting and recreating new instance..."
scripts/destroy-terraform.sh $1
scripts/apply-terraform.sh $1

echo "Switching to instance logs..."
scripts/watch-log.sh $1

echo "Connecting to instance..."
scripts/ssh-servername.sh $1
