#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete wireguard-again --wait || true
openstack stack create \
    --parameter "cluster_name=wordpress-again" \
    --parameter "cluster_template_name=wordpress-again-template" \
    --template projects/wordpress/wordpress_cluster.yaml \
    --wait \
    wordpress-again

projects/algo/setup.sh wireguard-again projects/algo/config.cfg

rm -rf projects/wordpress/.kube-again/config
openstack coe cluster config wordpress-again --dir projects/wordpress/.kube-again/ --use-certificate
cp -f projects/wordpress/.kube-again/config ~/.kube/config

exit

projects/cinder-csi-plugin/setup.sh
