#!/bin/bash

watch -cn1 openstack console log show $1 --lines 15
openstack console log show $1 > terraform-output.log