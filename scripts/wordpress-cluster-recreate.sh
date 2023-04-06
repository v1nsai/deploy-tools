#!/bin/bash

openstack coe cluster delete $1
openstack coe cluster create $1 \
    --cluster-template kubernetes-v1.23.3-rancher1 \
    --keypair techig-site \
    --master-count 1 \
    --node-count 1 \
    --master-flavor alt.st2.small \
    --flavor alt.st2.small \
    --fixed-network private_network \
    --fixed-subnet private_subnet1 