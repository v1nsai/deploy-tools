#!/bin/bash

source auth/alterncloud.env
openstack stack update -t $1 $2
sleep 10
openstack stack show $2 | grep -E 'stack_status|security_groups|output'
