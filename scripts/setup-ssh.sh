#!/bin/bash

# ssh setup
echo "Updating SSH settings..."
sed -i'' -e "s/[\#]*Port\s.*/Port 1355/" /etc/ssh/sshd_config
sed -i'' -e 's/[\#]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i'' -e '$aAllowUsers ubuntu' /etc/ssh/sshd_config
systemctl restart ssh