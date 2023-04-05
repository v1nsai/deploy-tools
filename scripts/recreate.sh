#!/bin/bash

set -e

source auth/.env
openstack stack delete -y $2 | true
sleep 5
openstack stack create -t $1 $2
