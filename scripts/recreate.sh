#!/bin/bash

source auth/alterncloud.env

openstack stack delete -y $2 --wait
openstack stack create -t $1 $2 --wait
openstack stack show $2 | grep -E 'stack_status|security_groups|output'