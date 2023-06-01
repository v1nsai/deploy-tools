#!/bin/bash

sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
apt-get install -y sudo git
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su stack && cd ~
git clone https://opendev.org/openstack/devstack
cat <<EOF > local.conf
[[local|localrc]]
FLOATING_RANGE=192.168.1.224/27
FIXED_RANGE=10.11.12.0/24
ADMIN_PASSWORD=";lkj;lkj"
DATABASE_PASSWORD=";lkj;lkj"
RABBIT_PASSWORD=";lkj;lkj"
SERVICE_PASSWORD=";lkj;lkj"
EOF
./stack.sh