#!/bin/bash

set -e

# Destroy and recreate the wordpress instance
scripts/destroy-terraform.sh wordpress
scripts/apply-terraform.sh wordpress
echo "Waiting for cloudinit to finish..."
sleep 60

# Provision and deploy the wordpress instance
projects/wordpress/trellis/trellis.sh doctor-ew.com provision staging
projects/wordpress/trellis/trellis.sh doctor-ew.com deploy staging