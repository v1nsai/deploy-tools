#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete $1 --wait || true
scripts/recreate-stack.sh $2 $3
projects/algo/setup.sh $1 $4

rm -rf ~/.kube/config
openstack coe cluster config $2 --dir ~/.kube --use-certificate

exit

projects/cinder-csi-plugin/setup.sh

scripts/redeploy-cluster.sh \
    wireguard \
    wordpress \
    projects/wordpress/wordpress_cluster.yaml \
    projects/algo/config.cfg

openstack server delete $1 --wait || true
openstack stack create \
    --parameter "cluster_name=wordpress-again" \
    --parameter "cluster_template_name=wordpress-template-again" \
    --template projects/wordpress/wordpress_cluster.yaml \
    --wait \
    wordpress-again

projects/algo/setup.sh wireguard-again projects/algo/config-again.cfg