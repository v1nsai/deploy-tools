#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete wireguard --wait || true
openstack stack delete -y wordpress --wait || true
openstack stack create \
    --parameter "cluster_name=wordpress" \
    --parameter "cluster_template_name=wordpress-template" \
    --template projects/wordpress/wordpress_cluster.yaml \
    --wait \
    wordpress

projects/algo/setup.sh wireguard projects/algo/config.cfg

rm -rf projects/wordpress/.kube/config || true
openstack coe cluster config wordpress --dir projects/wordpress/.kube/ --use-certificate
# cp -f projects/wordpress/.kube/config ~/.kube/config

exit

projects/cinder-csi-plugin/setup.sh
