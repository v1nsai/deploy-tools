#!/bin/bash

openstack server ssh $2 $1 -- -l drew -i auth/$1 $3