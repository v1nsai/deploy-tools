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
    # cp -f /opt/wp-deploy/nginx/conf-templates/default.conf.template /opt/wp-deploy/nginx/templates/default.conf.template
    # docker-compose restart nginx
else
    echo "Using existing certs..."
    docker-compose up -d
fi
