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
  # export CLOUDCONFIG=$(base64 -w 0 projects/$1/cloud-config.yaml)
  echo "Running predeploy..."
  projects/$1/predeploy.sh
else
  echo "No predeploy script found in projects/$1"
fi

# Apply terraform
terraform -chdir=projects/$1 init -upgrade
terraform -chdir=projects/$1 apply -var-file ../../auth/auth.tfvars -auto-approve

# Handle postdeploy if found
if [ -e $POSTDEPLOY ]; then
  # export CLOUDCONFIG=$(base64 -w 0 projects/$1/cloud-config.yaml)
  echo "Running postdeploy..."
  projects/$1/postdeploy.sh
else
  echo "No postdeploy script found in projects/$1"
fi