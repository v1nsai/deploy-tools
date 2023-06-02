#!/bin/bash

terraform -chdir=$1 init -upgrade
terraform -chdir=$1 apply -var-file ../../auth/auth.tfvars -auto-approve -target $2