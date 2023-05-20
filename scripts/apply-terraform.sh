#!/bin/bash

set -e

terraform -chdir=$1 init
terraform -chdir=$1 apply -var-file ../../auth/auth.tfvars -auto-approve