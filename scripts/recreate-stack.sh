#!/bin/bash

source auth/alterncloud.env
set -e

# openstack stack delete -y $2 --wait || true
echo $1 $2 $3
openstack stack create -t $1 $2 --wait $3
openstack stack show $2 | grep -E 'stack_status|output'