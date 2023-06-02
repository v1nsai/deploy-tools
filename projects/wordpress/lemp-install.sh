#!/bin/bash

set -e

# Set both of these to custom domain or indicated defaults
# default none
DOMAIN_OR_NONE=
# default "default"
DOMAIN_OR_DEFAULT="default"

# Install packages
apt update || true
apt install -y nginx mariadb-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

# Configure mariadb
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

# Configure nginx
mkdir -p /var/www/$DOMAIN_OR_NONE 
chown -R wordpress:wordpress /var/www/$DOMAIN_OR_NONE
touch /etc/nginx/sites-available/$DOMAIN_OR_DEFAULT
echo "# generated 2023-05-29, Mozilla Guideline v5.7, nginx 1.17.7, OpenSSL 1.1.1k, intermediate configuration
# https://ssl-config.mozilla.org/#server=nginx&version=1.17.7&config=intermediate&openssl=1.1.1k&guideline=5.7
server {
    listen 80;
    listen [::]:80;

    root /var/www/$DOMAIN_OR_NONE;
    index index.php index.html index.htm;

    server_name $DOMAIN_OR_DEFAULT;

    location / {
        # try_files $uri $uri/ =404;
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    # Digitalocean wordpress
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt { log_not_found off; access_log off; allow all; }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }
}

# server {
#     listen 443 ssl http2;
#     listen [::]:443 ssl http2;

#     ssl_certificate /path/to/signed_cert_plus_intermediates;
#     ssl_certificate_key /path/to/private_key;
#     ssl_session_timeout 1d;
#     ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
#     ssl_session_tickets off;

#     # curl https://ssl-config.mozilla.org/ffdhe2048.txt > /path/to/dhparam
#     ssl_dhparam /path/to/dhparam;

#     # intermediate configuration
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
#     ssl_prefer_server_ciphers off;

#     # HSTS (ngx_http_headers_module is required) (63072000 seconds)
#     add_header Strict-Transport-Security "max-age=63072000" always;

#     # OCSP stapling
#     ssl_stapling on;
#     ssl_stapling_verify on;

#     # verify chain of trust of OCSP response using Root CA and Intermediate certs
#     ssl_trusted_certificate /path/to/root_CA_cert_plus_intermediates;

#     # replace with the IP address of your resolver
#     resolver 127.0.0.1;
#}" > /etc/nginx/sites-available/$DOMAIN_OR_DEFAULT
ln -s /etc/nginx/sites-available/$DOMAIN_OR_DEFAULT /etc/nginx/sites-enabled/$DOMAIN_OR_DEFAULT || true

# Update certs
/usr/sbin/update-ca-certificates

nginx -t
systemctl reload nginx

# Install wordpress
rm -rf /var/www/html/*
wget -P /tmp/ https://wordpress.org/latest.zip
unzip /tmp/latest.zip -d /tmp
mv /tmp/wordpress/* /var/www/$DOMAIN_OR_NONE

# Fix folder permissions
chmod 755 -R /var/www/
chown www-data:www-data -R /var/www/