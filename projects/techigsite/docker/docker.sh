#!/bin/bash

set -e
cd /opt/wp-deploy

# TODO REMOVE FOR TESTING ONLY
docker-compose down
rm -rf /opt/wp-deploy/nginx/ssl

# Error on invalid DOMAIN or SSL_PROVISIONER
if [[ -z "$DOMAIN" ]]; then
    echo "Please set the DOMAIN environment variable."
    exit 1
fi

if [[ "$SSL_PROVISIONER" == "manual" ]] || [[ "$SSL_PROVISIONER" == "letsencrypt" ]]; then
    echo "SSL_PROVISIONER set to $SSL_PROVISIONER."
else
    echo "SSL_PROVISIONER not set to a valid value, defaulting to letsencrypt..."
    SSL_PROVISIONER="letsencrypt"
fi

if [[ "$DOMAIN" == "temporary" ]]; then
    if [[ "$SSL_PROVISIONER" == "manual" ]]; then
        echo "Can't use manual SSL_PROVISIONER with temporary domain name."
        exit 1
    fi
    echo "Creating a temporary domain name..."
    SUBDOMAIN=$(./create-temp-record.sh doctor-ew.com)
    echo "Temporary domain name created: $SUBDOMAIN"
    DOMAIN="$SUBDOMAIN"
    sed -i '/DOMAIN/d' /etc/environment
    echo "DOMAIN=$SUBDOMAIN" | tee -a /etc/environment
    echo "Your site will be available at https://$DOMAIN"
fi

# Deploy wordpress using SSL_PROVISIONER
if [[ "$SSL_PROVISIONER" == "letsencrypt" ]]; then
    echo "Provisioning SSL certificates with letsencrypt..."
    mkdir -p ./nginx/templates
    cp -f ./nginx/conf-templates/certbot.conf.template ./nginx/templates/default.conf.template
    docker-compose up -d
    echo "Starting services..."
    echo "Sleeping 10s to wait for services to start..."
    sleep 10
    cp -f ./nginx/conf-templates/default.conf.template ./nginx/templates/default.conf.template
    docker-compose restart nginx
fi

if [[ "$SSL_PROVISIONER" == "manual" ]]; then
    echo "Using user-supplied ssl certificates..."
    if [[ -f "./nginx/ssl/live/$DOMAIN/fullchain.pem" ]] && [[ -f "./nginx/ssl/live/$DOMAIN/privkey.pem" ]]; then
        echo "SSL certificates found."
        mkdir -p ./nginx/templates
        cp -f ./nginx/conf-templates/default.conf.template ./nginx/templates/default.conf.template
        docker-compose up -d 
    fi
fi

# Set admin password if provided
if [[ -n "$ADMIN_PASSWD" ]]; then
    echo "Setting admin password..."
    echo 'localadmin:'"$ADMIN_PASSWD" | sudo chpasswd
fi

# Remove script from crontab after running successfully
(sudo crontab -l | grep -v "$SEARCH_STRING") | sudo crontab -
