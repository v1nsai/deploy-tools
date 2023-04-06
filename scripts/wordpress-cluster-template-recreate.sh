#!/bin/bash

openstack coe cluster delete $1
openstack coe cluster template delete $1
openstack coe cluster template create $1 \
    -f yaml \
    --coe kubernetes \
    --image 'Fedora CoreOS (37.20230205.3.0-stable)' \
    --fixed-network private_network \
    --fixed-subnet private_subnet1 \
    --external-network External \
    --keypair techig-site \
    --dns-nameserver 1.1.1.1 \
    --dns-nameserver 1.0.0.1 \
    --flavor alt.gp2.large \
    --master-flavor alt.gp2.large \
    --floating-ip-disabled \
    --volume-driver cinder \
    --docker-storage-driver overlay \
    --docker-volume-size 20 \
    --master-lb-enabled \
    --network-driver calico

openstack coe cluster create $1 \
    --cluster-template $1 \
    --master-count 1 \
    --node-count 1 \
    --floating-ip-disabled

# this works but ignores disabling floating ip
# openstack coe cluster create kubernetes-v1.23.3-rancher1 \
#     --cluster-template kubernetes-v1.23.3-rancher1 \
#     --master-count 1 \
#     --node-count 1 \
#     --floating-ip-disabled