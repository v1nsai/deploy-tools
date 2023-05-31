#!/bin/bash

set -e

rm -rf projects/wireguard/configs
IP=$(openstack server show wireguard -f json | jq '.addresses.kubeflow[] | select(startswith("216"))' | tr -d '"')
scp -ri auth/wireguard drew@$IP:/opt/algo/configs/ projects/wireguard/configs