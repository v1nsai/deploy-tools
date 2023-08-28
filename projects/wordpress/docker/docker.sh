#!/bin/bash

set -e
cd /opt/wp-deploy

# Error on invalid DOMAIN or SSL_PROVISIONER
if [[ -z "$DOMAIN" ]]; then
    echo "Please set the DOMAIN environment variable."
    exit 1
fi

# Parse DOMAIN and error if invalid
echo "Setting DOMAIN and SUBDOMAIN environment variables..."
if [[ $DOMAIN =~ (https?:\/\/)?([a-z]+)\.([a-z]*\.[a-z]{3}) ]]; then
    echo 1
    SUBDOMAIN="${BASH_REMATCH[2]}"
    DOMAIN="${BASH_REMATCH[3]}"
    SEP='.'
elif [[ $DOMAIN =~ (https?:\/\/)?([a-z]*\.[a-z]{3}$) ]]; then
    echo 2
    DOMAIN="${BASH_REMATCH[2]}"
    DOMAIN="$SUBDOMAIN$SEP$DOMAIN"
    SUBDOMAIN=
    ONLY_SUBDOMAINS=false
    SEP=
elif [[ "$DOMAIN" == "temporary" ]]; then
    echo "Creating a temporary domain name..."
    SUBDOMAIN=$(echo "temp$RANDOM")
    DOMAIN="techig.com"
    SEP='.'
else
    echo "Invalid domain name: $DOMAIN"
    exit 1
fi
FULL_DOMAIN="$SUBDOMAIN$SEP$DOMAIN"
echo "FULL_DOMAIN=$FULL_DOMAIN" | sudo tee -a /etc/environment
echo "SUBDOMAIN=$SUBDOMAIN" | sudo tee -a /etc/environment
echo "DOMAIN=$DOMAIN" | sudo tee -a /etc/environment
echo "ONLY_SUBDOMAINS=$ONLY_SUBDOMAINS" | sudo tee -a /etc/environment
while read -r env; do export "$env"; done # set variables system-wide immediately
echo "Your site will be available at https://$FULL_DOMAIN"

# Use envsubst on the nginx template to create the nginx config
mkdir -p ./swag/nginx/site-confs
envsubst '$FULL_DOMAIN' < default.conf.template > ./swag/nginx/site-confs/default.conf
 
docker-compose up -d

# Remove front crontab when finished
sudo crontab -r