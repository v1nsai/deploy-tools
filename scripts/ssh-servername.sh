#!/bin/bash
source auth/alterncloud.env
openstack server ssh $2 $1 -- -l localadmin -i ~/.ssh/$1 $3