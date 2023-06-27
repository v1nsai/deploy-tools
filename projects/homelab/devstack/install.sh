#!/bin/bash

set -e

# initial install
git clone https://opendev.org/openstack/devstack
cd devstack
sudo tools/create-stack-user.sh
# sudo passwd stack
sudo su stack -c ./stack.sh

# Fix DNS on br-ex network
sudo rm -f /etc/resolv.conf
sudo ln -sv /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Fix accessing floating IPs
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo echo 1 > /proc/sys/net/ipv4/conf/enp10s0/proxy_arp
sudo iptables -t nat -A POSTROUTING -o enp10s0 -j MASQUERADE
