#!/bin/bash

set -e
DOMAIN=

echo "Configuring mariadb..."
systemctl stop mysql
killall -9 mysqld_safe mysqld mariadb mariadbd mysql || true
echo "Disabling grant tables and networking"
mysqld_safe --skip-grant-tables --skip-networking &>/dev/null & disown
echo "Waiting for mysql to start"
sleep 10
mysql -uroot -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; "
killall -9 mysqld_safe mariadbd || true
echo "Restarting mysql"
systemctl start mysql

mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY '${MYSQL_WP_USER_PASSWORD}';
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost';
FLUSH PRIVILEGES; "

# Configure php
systemctl restart php7.4-fpm

echo "Configuring nginx..."
mkdir -p /var/www/$DOMAIN
chown -R wordpress:wordpress /var/www/$DOMAIN
touch /etc/nginx/sites-available/${DOMAIN:-"default"}
ln -s /etc/nginx/sites-available/${DOMAIN:-"default"} /etc/nginx/sites-enabled/${DOMAIN:-"default"} || true

# Update certs
# /usr/sbin/update-ca-certificates

nginx -t
systemctl reload nginx

# Install wordpress
rm -rf /var/www/html/*
wget -P /tmp/ https://wordpress.org/latest.zip
unzip /tmp/latest.zip -d /tmp
mv /tmp/wordpress/* /var/www/$DOMAIN

# Fix folder permissions
chmod 755 -R /var/www/
chown www-data:www-data -R /var/www/

# Transfer files from postdeploy.zip to proper places
mv /tmp/auth/pki/ca.crt /etc/ssl/certs/techig-ca.crt
mv /tmp/auth/pki/issued/wordpress.crt /etc/ssl/certs/wordpress.crt
mv /tmp/auth/pki/private/wordpress.key /etc/ssl/private/wordpress.key
mv /tmp/projects/wordpress/nginx-domain /etc/nginx/sites-available/$DOMAIN

# Generate dhparam
curl https://ssl-config.mozilla.org/ffdhe2048.txt > /etc/nginx/dhparam

# cleanup
rm -rf /tmp/latest.zip /tmp/wordpress /tmp/postdeploy.zip /tmp/auth /tmp/projects