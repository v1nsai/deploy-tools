#!/bin/bash
set -e 

terraform -chdir=projects/wordpress init
terraform -chdir=projects/wordpress apply -var-file ../../auth/auth.tfvars -auto-approve
