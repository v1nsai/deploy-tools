#!/bin/bash

set -e 
source auth/alterncloud.env

# download, extract, convert
wget https://bitnami.com/redirect/to/2319964/bitnami-wordpress-6.2.2-r0-debian-11-amd64.ova projects/wordpress/bitnami/ || true
tar xvf projects/wordpress/bitnami/bitnami-wordpress-6.2.1-r0-debian-11-amd64.ova -C projects/wordpress/bitnami/
mkdir -p projects/wordpress/bitnami/extracted || true
cd projects/wordpress/bitnami/extracted
rm -rf *
7z x ../bitnami-wordpress-6-6.2.1-r0-debian-11-amd64-disk-0.vmdk
cd $(git rev-parse --show-toplevel)

# mount
qemu-img convert projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-r0-debian-11-amd64-disk-0.vmdk bitnami-wordpress-6-6.2.1-r0-debian-11-amd64-disk-0.raw
losetup -f bitnami-wordpress-6-6.2.1-r0-debian-11-amd64-disk-0.raw

# repackage
rm -rf projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-custom.iso || true
# mkisofs -D -o projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-custom.iso projects/wordpress/bitnami/extracted
# qemu-img convert projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-custom.iso projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-custom.vmdk
# qemu-img create bitnami-wordpress-custom.vmdk 2G
# losetup -f bitnami-wordpress-custom.vmdk


# upload
openstack image delete bitnami-wordpress-6-6.2.1-custom || true
openstack image create --disk-format vmdk --container-format bare --file projects/wordpress/bitnami/bitnami-wordpress-6-6.2.1-custom.vmdk bitnami-wordpress-6-6.2.1-custom

# redeploy
openstack server delete bitnami-wordpress-custom || true
openstack server create --image bitnami-wordpress-6-6.2.1-custom --flavor alt.st2.medium --key-name wordpress --network wordpress --wait bitnami-wordpress-custom
watch -cn1 openstack console log show bitnami-wordpress-custom --lines 25