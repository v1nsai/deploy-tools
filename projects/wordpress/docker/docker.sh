#!/bin/bash

set -e
cd /opt/wp-deploy
mv nginx/templates nginx/templates-disabled

docker-compose down
if [ ! -d "/opt/wp-deploy/nginx/ssl" ]; then
    echo "Generating self-signed certs to start nginx..."
    mkdir -p /opt/wp-deploy/nginx/ssl/live/$DOMAIN
    /opt/wp-deploy/generate_certs.sh /opt/wp-deploy/nginx/ssl/live/$DOMAIN/fullchain.pem /opt/wp-deploy/nginx/ssl/live/$DOMAIN/privkey.pem
    
    docker-compose up -d nginx
    rm -rf /opt/wp-deploy/nginx/ssl
    mkdir -p /opt/wp-deploy/nginx/ssl
    docker-compose up -d certbot
    docker-compose restart nginx
    docker-compose up -d
else
    echo "Using existing certs..."
    docker-compose up -d
fi

if [[ $1 -gt 0 ]]; then
    docker logs -f $1
fi
