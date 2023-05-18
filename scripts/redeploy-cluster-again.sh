#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete wordpress-again --wait || true
openstack stack create \
    --parameter "cluster_name=wordpress-again" \
    --parameter "cluster_template_name=wordpress-template-again" \
    --template projects/wordpress/wordpress_cluster.yaml \
    --wait \
    wordpress-again

projects/algo/setup.sh wireguard-again projects/algo/config-again.cfg