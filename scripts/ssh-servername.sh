#!/bin/bash

openstack server ssh $2 $1 -- -l drew -i ~/.ssh/$1 $3