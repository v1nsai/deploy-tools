#!/bin/bash

set -e

rm -rf ~/.kube
mkdir -p ~/.kube
openstack coe cluster config wordpress --dir ~/.kube --use-certificate
