#!/bin/bash

# ssh setup
sed -i'' -e "s/[\#]*Port\s.*/Port 1355/" /etc/ssh/sshd_config
sed -i'' -e 's/[\#]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i'' -e '$aAllowUsers drew' /etc/ssh/sshd_config
systemctl restart ssh

# get the latest wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

# Install mysql and phpmyadmin
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get install mysql-server -y

echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | sudo debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | sudo debconf-set-selections
sudo apt-get install phpmyadmin -y