#!/bin/bash

set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=$PWD/terraform.log

PREDEPLOY=$(echo projects/$1/predeploy.sh)
POSTDEPLOY=$(echo projects/$1/postdeploy.sh)

# Handle predeploy if found
if [ -e $PREDEPLOY ]; then
  echo "Running predeploy..."
  projects/$1/predeploy.sh
else
  echo "No predeploy script found in projects/$1"
fi

terraform -chdir=projects/$1/terraform init -upgrade
terraform -chdir=projects/$1/terraform destroy -auto-approve
