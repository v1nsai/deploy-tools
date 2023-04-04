#!/bin/bash

set -e

source auth/.env
openstack stack delete -y $2 | true \
openstack stack create -t $1 $2 && \
watch "openstack stack show $2 | grep -E 'stack_status|security_groups|output'"
