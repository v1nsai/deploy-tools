#!/bin/bash

set -e
cd /opt/wp-deploy

docker-compose down
rm -rf /opt/wp-deploy/nginx/ssl
if [ ! -d "/opt/wp-deploy/nginx/ssl" ]; then
    echo "Generating certs..."
    mkdir -p /opt/wp-deploy/nginx/templates
    cp -f /opt/wp-deploy/nginx/conf-templates/certbot.conf.template /opt/wp-deploy/nginx/templates/default.conf.template
    
    docker-compose up -d
    echo "Starting services..."
    echo "Sleeping 10s to wait for services to start..."
    sleep 10
    cp -f /opt/wp-deploy/nginx/conf-templates/default.conf.template /opt/wp-deploy/nginx/templates/default.conf.template
    docker-compose restart nginx
else
    echo "Using existing certs and starting services..."
    docker-compose up -d
fi
