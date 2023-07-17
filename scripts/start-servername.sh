#!/bin/bash

set -e
source auth/alterncloud.env

openstack server start $1