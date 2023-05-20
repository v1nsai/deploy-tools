#!/bin/bash

source auth/alterncloud.env
set -e

openstack stack delete -y $2 --wait || true
echo $1 $2 $3
openstack stack create -t $1 $2 --wait $3

export STACK_EXTERNAL_IP=$(openstack stack show $2 -f json | jq '.outputs[] | select(.output_key == "server_public_ip") | .output_value')

cat << EOF > ~/.ssh/config.auto
Host *
	StrictHostKeyChecking no

Host $2
	HostName $STACK_EXTERNAL_IP
	Port 1355
	User drew
	IdentityFile /Users/doctor_ew/.ssh/jump-server
EOF

# ssh alias for custom ssh file because I hate sed 
alias ssha="ssh -F ~/.ssh/config.auto"
alias sshos="openstack server ssh"

watch -c -n 1 openstack console log show --lines 20 $2