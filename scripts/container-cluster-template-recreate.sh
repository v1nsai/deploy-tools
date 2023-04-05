#!/bin/bash

openstack coe cluster template delete $1
sleep 10
openstack coe cluster template create $1 \
    -f yaml \
    --coe kubernetes \
    --image 'Fedora CoreOS (37.20230205.3.0-stable)' \
    --external-network External \
    --fixed-network dmz_network \
    --fixed-subnet dmz_subnet1 \
    --keypair nextcloud \
    --dns-nameserver 1.1.1.1 \
    --dns-nameserver 1.0.0.1 \
    --flavor alt.s2.2xlarge \
    --master-flavor alt.s2.2xlarge \
    --floating-ip-enabled
