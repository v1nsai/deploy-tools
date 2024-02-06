#!/bin/bash

set -e

# echo "Copying nginx templates..."
# sudo mkdir -p /config/nginx/templates
# sudo chown -R $USER:$USER /config/nginx/templates
# cp nginx_templates/* /config/nginx/templates

source /etc/environment
echo "Generating /opt/deploy/.env file..."
if [[ -f /opt/deploy/.env ]]; then
    source /opt/deploy/.env
fi
if [[ -z "$OPENPROJECT_HOST__NAME" ]]; then
    echo "Please enter the URL of your OpenProject instance (e.g. https://www.openproject.org):"
    read OPENPROJECT_HOST__NAME
    OPENPROJECT_HOST__NAME=$(echo $OPENPROJECT_HOST__NAME | sed 's/https\?:\/\///')
    echo "OPENPROJECT_HOST__NAME='$OPENPROJECT_HOST__NAME'" | tee -a /opt/deploy/.env
fi
if [[ -z "$OPENPROJECT_ADMIN__EMAIL" ]]; then
    echo "Please enter the email address of the OpenProject admin user:"
    read OPENPROJECT_ADMIN__EMAIL
    echo "OPENPROJECT_ADMIN__EMAIL='$OPENPROJECT_ADMIN__EMAIL'" | tee -a /opt/deploy/.env
fi
echo "OPENPROJECT_SECRET_KEY_BASE='$(openssl rand -base64 32)'" | tee -a /opt/deploy/.env
echo "OPENPROJECT_HTTPS='true'" | tee -a /opt/deploy/.env
echo "COMPOSE_PROJECT_NAME=openproject" | tee -a /opt/deploy/.env
source /opt/deploy/.env

echo "Starting OpenProject..."
docker compose -f /opt/deploy/docker-compose.yml up -d

echo "Configuring HTTPS..."
mkdir -p /etc/nginx/conf
docker compose -f /opt/deploy/proxy-docker-compose.yml up -d
docker compose -f /opt/deploy/proxy-docker-compose.yml run --rm certbot certonly --no-eff-email --agree-tos --email $OPENPROJECT_ADMIN__EMAIL --webroot --webroot-path /var/www/certbot/ -d $OPENPROJECT_HOST__NAME
envsubst '$OPENPROJECT_HOST__NAME' < /etc/nginx/templates/openproject.conf.template > /etc/nginx/conf/openproject.conf
docker compose -f /opt/deploy/proxy-docker-compose.yml restart nginx
echo "0 3 * * 1 docker compose -f /opt/deploy/proxy-docker-compose.yml run --rm certbot renew > /var/log/certbot_renew.log 2>&1" > /etc/cron.d/renew-certs
echo "0 3 * * 1 docker restart nginx >> /var/log/certbot_renew.log 2>&1" > /etc/cron.d/restart-proxy
