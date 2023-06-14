#!/bin/bash

set -e
source auth/alterncloud.env

rm -rf projects/$1/configs
IP=$(openstack server show $2 -f json | jq '.addresses.wordpress[] | select(startswith("216"))' | tr -d '"')
scp -ri auth/wireguard localadmin@$IP:/opt/algo/configs/ projects/$1/wg-configs