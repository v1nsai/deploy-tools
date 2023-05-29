#!/bin/bash

set -e
source auth/alterncloud.env

DOMAIN="your_domain"

# Install packages
sudo apt update
sudo apt install -y nginx mariadb-server php-fpm php-mysql

# Configure mariadb
sudo mysql_secure_installation
mariadb -u wp-user -p

# Configure nginx
sudo mkdir /var/www/$DOMAIN
sudo chown -R $USER:$USER /var/www/$DOMAIN
sudo touch /etc/nginx/sites-available/$DOMAIN
echo "server {
        listen 80;
        listen [::]:80;

        root /var/www/your_domain;
        index index.php index.html index.htm;

        server_name your_domain;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        }
    }" > /etc/nginx/sites-available/$DOMAIN
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Install wordpress
wget https://wordpress.org/latest.zip