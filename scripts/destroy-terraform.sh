#!/bin/bash

set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=$PWD/terraform.log

terraform -chdir=$1 destroy -auto-approve -var-file=../../auth/auth.tfvars
