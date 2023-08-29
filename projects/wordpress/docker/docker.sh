#!/bin/bash

set -e
cd /opt/wp-deploy

# Error on invalid DOMAIN or SSL_PROVISIONER
if [[ -z "$DOMAIN" ]]; then
    echo "Please set the DOMAIN environment variable."
    exit 1
fi

# Parse DOMAIN and error if invalid
if [[ "$DOMAIN" == "temporary" ]]; then
    echo "Creating a temporary domain name..."
    SUBDOMAIN=$(echo "temp$RANDOM")
    DOMAIN="techig.com"
else
    echo "Invalid domain name: $DOMAIN"
    exit 1
fi

echo "Your site will be available at https://$FULL_DOMAIN"

# Use envsubst on the nginx template to create the nginx config
mkdir -p ./swag/nginx/site-confs
envsubst '$DOMAIN' < default.conf.template > ./swag/nginx/site-confs/default.conf

docker-compose up -d

# Remove from crontab when finished
sudo crontab -r