#!/bin/bash

set -e

openstack coe cluster config $1 --dir ~/.kube --use-certificate --force
docker cp ~/.kube/config ubuntudev:/home/vscode/.kube/config