#!/bin/bash

openstack server ssh --private $1 -- -l drew -i auth/$1 -p 1355