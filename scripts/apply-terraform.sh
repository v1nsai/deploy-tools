#!/bin/bash

set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=$PWD/terraform.log

rm -rf $PWD/terraform.log

terraform -chdir=$1 init
terraform -chdir=$1 apply -var-file ../../auth/auth.tfvars -auto-approve
