#!/bin/bash

set -e

rm -rf ~/.kube
mkdir -p ~/.kube
openstack coe cluster config $1 --dir ~/.kube --use-certificate --force
docker cp ~/.kube/config ubuntudev:/home/vscode/.kube/config
