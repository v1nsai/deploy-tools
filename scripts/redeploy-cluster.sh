#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete wireguard
scripts/recreate-stack.sh heat-templates/coe_cluster.yaml wordpress
projects/algo/setup.sh