#!/bin/bash

set -e

python3 -m http.server --directory projects/wordpress/packer/cloud-data &> /dev/null &
qemu-system-x86_64                                              \
    -net nic                                                    \
    -net user                                                   \
    -m 512                                                      \
    -nographic                                                  \
    -hda output-$1/$1                                           \
    -smbios type=1,serial=ds='nocloud-net;s=http://localhost:8000/'
killall Python
echo "Completed successfully"

# terraform -chdir=templates/terraform/test init -var-file="../../../auth/alterncloud.auto.tfvars"
# terraform -chdir=templates/terraform/test apply -target="openstack_compute_instance_v2.instance" -var-file="../../../auth/alterncloud.auto.tfvars" -auto-approve