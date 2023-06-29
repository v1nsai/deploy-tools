#!/bin/bash

# Set error handling and logging
set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
rm -rf terraform.log

PREDEPLOY=$(echo projects/$1/predeploy.sh)
POSTDEPLOY=$(echo projects/$1/postdeploy.sh)

# Handle predeploy if found
if [ -e $PREDEPLOY ]; then
  echo "Running predeploy..."
  projects/$1/predeploy.sh
else
  echo "No predeploy script found in projects/$1"
fi

# Apply terraform
terraform -chdir=projects/$1/terraform init -upgrade
terraform -chdir=projects/$1/terraform apply -auto-approve
echo "Terraform apply completed"

# Handle postdeploy if found
if [ -e $POSTDEPLOY ]; then
  echo "Running postdeploy..."
  bash -c "projects/$1/postdeploy.sh"
else
  echo "No postdeploy script found in projects/$1"
fi