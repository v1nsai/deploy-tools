#!/bin/bash

openstack server ssh $2 $1 -- -l drew -i auth/$1 -p 1355 $3