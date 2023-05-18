#!/bin/bash

set -e
source auth/alterncloud.env

openstack server delete $1 --wait || true
scripts/recreate-stack.sh $2 $3
projects/algo/setup.sh

rm -rf ~/.kube/config
openstack coe cluster config $3 --dir ~/.kube --use-certificate

exit

projects/cinder-csi-plugin/setup.sh