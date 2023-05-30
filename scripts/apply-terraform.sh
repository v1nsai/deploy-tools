#!/bin/bash

# Set error handling and logging
set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
rm -rf terraform.log

# Handle cloud-config file if found
if [ -e "$1/cloud-config.yaml" ]; then
# export CLOUDCONFIG=$(base64 -w 0 $1/cloud-config.yaml)
echo "Update cloud-config.yaml in terraform file"
$1/update-cloud-config.sh # if update script found, run before adding to the terraform config file
sed -i 's/base64decode([^)]*)/base64decode("'"$(base64 -w 0 $1/cloud-config.yaml)"'")/g' projects/wordpress/cloud-init.tf
else
  echo "No cloud-config.yaml file found in $1"
fi

# Apply terraform
terraform -chdir=$1 init -upgrade
terraform -chdir=$1 apply -var-file ../../auth/auth.tfvars -auto-approve