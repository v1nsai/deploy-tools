#!/bin/bash

source auth/alterncloud.env
set -e

openstack stack delete -y $2 --wait | true
openstack stack create -t $1 $2 --wait
openstack stack show $2 | grep -E 'stack_status|security_groups|output'