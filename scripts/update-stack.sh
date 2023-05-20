#!/bin/bash

openstack stack update --wait -t $1 $2
