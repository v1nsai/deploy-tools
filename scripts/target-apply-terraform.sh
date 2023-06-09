#!/bin/bash
set -e
terraform -chdir=projects/$1 init -upgrade
terraform -chdir=projects/$1 apply -auto-approve -target=$2