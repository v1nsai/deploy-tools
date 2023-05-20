#!/bin/bash

export SSH_PUBKEY=`cat ~/.ssh/wireguard.pub`

cd projects/wireguard
terraform init
terraform apply -var-file ../../auth/auth.tfvars -auto-approve