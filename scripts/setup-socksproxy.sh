#!/bin/bash

set -e

echo "Installing and configuring socks proxy..."
apt update
apt install -y dante-server
rm /etc/danted.conf || true

mv /home/drew/danted.conf /etc/danted.conf
systemctl restart danted

# danted.conf
# logoutput: syslog
# user.privileged: root
# user.unprivileged: nobody

# # The listening network interface or address.
# internal: 0.0.0.0 port=1080

# # The proxying network interface or address.
# external: ens3

# # socks-rules determine what is proxied through the external interface.
# socksmethod: none

# # client-rules determine who can connect to the internal interface.
# clientmethod: none

# client pass {
#     from: 0.0.0.0/0 to: 0.0.0.0/0
# }

# socks pass {
#     from: 0.0.0.0/0 to: 0.0.0.0/0
# }