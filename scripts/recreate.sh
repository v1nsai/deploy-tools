#!/bin/bash

set -e

source auth/.env
openstack stack delete -y $2 | true
sleep 5
openstack stack create -t $1 $2
sleep 20
openstack stack show $2 | grep -E 'stack_status|security_groups|output'
