#!/bin/bash

set -e
cd /opt/wp-deploy

# TODO REMOVE FOR TESTING ONLY
docker-compose down
rm -rf /opt/wp-deploy/nginx/ssl

# Error on invalid DOMAIN or SSL_PROVISIONER
if [[ -z "$DOMAIN" ]] || [[ -z "$SSL_PROVISIONER" ]]; then
    echo "Please set the DOMAIN and SSL_PROVISIONER environment variables."
    exit 1
fi

if [[ "$SSL_PROVISIONER" == "manual" ]] || [[ "$SSL_PROVISIONER" == "certbot" ]] || [[ "$SSL_PROVISIONER" == "selfsigned" ]]; then
    echo "SSL_PROVISIONER set to $SSL_PROVISIONER."
else
    echo "SSL_PROVISIONER not set to a valid value, defaulting to certbot..."
    SSL_PROVISIONER="certbot"
fi

if [[ "$DOMAIN" == "temporary" ]]; then
    if [[ "$SSL_PROVISIONER" == "manual" ]]; then
        echo "Can't use manual SSL_PROVISIONER with temporary domain name."
        exit 1
    fi
    echo "Creating a temporary domain name..."
    DOMAIN=$(./create-temp-record.sh $DOMAIN)
    echo "Your site will be available at https://$DOMAIN"
fi

# Deploy wordpress using SSL_PROVISIONER
if [[ "$SSL_PROVISIONER" == "certbot" ]]; then
    echo "Provisioning SSL certificates with certbot..."
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

# Remove script from crontab after running successfully
(sudo crontab -l | grep -v "$SEARCH_STRING") | sudo crontab -
