#!/bin/bash

source auth/alterncloud.env

openstack stack delete -y jump-server --wait
openstack stack create -t templates/jump-server.yaml jump-server --wait
openstack stack show jump-server | grep -E 'stack_status|security_groups|output'