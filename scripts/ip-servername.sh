#!/bin/bash

openstack server show $1 -f json | jq -r ".addresses.$1[0]"