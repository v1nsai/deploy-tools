#!/bin/bash

# Set error handling and logging
set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
rm -rf terraform.log

CLOUDCONFIG=$(echo projects/$1/cloud-config.yaml)
UPDATESCRIPT=$(echo projects/$1/update-cloud-config.sh)

# Handle cloud-config file if found
if [ -e $UPDATESCRIPT ]; then
  # export CLOUDCONFIG=$(base64 -w 0 projects/$1/cloud-config.yaml)
  echo "Update cloud-config.yaml in terraform file"
  projects/$1/update-cloud-config.sh # if update script found, run before adding to the terraform config file
  sed -i 's/base64decode([^)]*)/base64decode("'"$(base64 -w 0 $CLOUDCONFIG)"'")/g' projects/$1/cloud-init.tf
else
  echo "No cloud-config.yaml file found in projects/$1"
fi

# Apply terraform
terraform -chdir=projects/$1 init -upgrade
terraform -chdir=projects/$1 apply -var-file ../../auth/auth.tfvars -auto-approve