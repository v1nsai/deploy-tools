#!/bin/bash

source auth/alterncloud.env

openstack stack delete -y $2
sleep 5
openstack stack create -t $1 $2
