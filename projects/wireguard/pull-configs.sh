#!/bin/bash

set -e

# Pull config files from server
rm -rf projects/$1/wg-configs
IP=$(openstack server show $2 -f json | jq '.addresses.wordpress[] | select(startswith("216"))' | tr -d '"')
scp -ri auth/wireguard drew@$IP:/opt/algo/configs/ projects/$1/wg-configs/