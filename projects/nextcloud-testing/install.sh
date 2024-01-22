#!/bin/bash

# set -e
cd /opt/deploy

echo "Generating /opt/deploy/.env file..."
if [ -f /opt/deploy/.env ]; then
    source /opt/deploy/.env
else
    echo "COMPOSE_PROJECT_NAME=nextcloud" | tee -a .env
    source .env
fi

install() {
    echo "Setting up WordPress with SSL..."
    if [[ -z "$URL" ]]; then
        echo "URL variable not set, defaulting to self-signed certificate..."
        return 1
    fi
    URL=$(echo $URL | sed 's/https\?:\/\///g') # strip http(s):// from URL
    echo "Your site will be available at https://$URL"

    echo "Creating nginx config..."
    mkdir -p /config/nginx/site-confs
    rm -rf /config/nginx/site-confs/nextcloud.conf
    curl -o /config/nginx/site-confs/nextcloud.conf https://raw.githubusercontent.com/linuxserver/reverse-proxy-confs/master/nextcloud.subdomain.conf.sample
    sed -i "s/server_name.*$/server_name $URL;/g" /config/nginx/site-confs/nextcloud.conf
    
    echo "Starting containers..."
    docker compose --profile selfsigned down nginx
    docker compose --profile swag -f /opt/deploy/docker-compose.yaml up -d
    while [[ ! -f /config/etc/letsencrypt/live/${URL}/fullchain.pem ]] && [[ ! -f /config/etc/letsencrypt/live/${URL}/privkey.pem ]]; do
        echo "Waiting for SSL certs and keys to be generated..."
        sleep 10
    done
    rm -f /config/nginx/ssl/privkey.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/fullchain.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/privkey.pem /config/nginx/ssl/privkey.pem
    docker restart swag
}

install-self-signed() {
    echo "Creating a self-signed certificate..."
    URL=$(curl -s ifconfig.io)
    mkdir -p /config/nginx/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /config/nginx/ssl/privkey.pem -x509 -days 365 -out /config/nginx/ssl/fullchain.pem -subj "/CN=$URL/emailAddress=support@techig.com/C=US"

    echo "Your site will be available at https://$URL"
    rm -rf /config/nginx/site-confs/nextcloud.conf
    envsubst '$URL' < /config/nginx/conf-templates/nextcloud.conf.template > /config/nginx/site-confs/nextcloud.conf

    docker compose -f /opt/deploy/docker-compose.yaml --profile selfsigned up -d
}

cleanup() {
    echo "Checking health status of containers..."
    sleep 30
    for container in "nextcloud-aio-mastercontainer" "swag"; do
        healthcheck $container
    done
    sudo crontab -r
    echo "Deleting install files..."
    cd
    rm -rf /opt/deploy
    echo "Finished cleanup"
}

healthcheck() {
    echo "Checking health status of container $1..."
    while [[ $(docker inspect -f '{{.State.Health.Status}}' $1) == "starting" ]]; do
        echo "Container $1 is still starting..."
        sleep 10
    done
    if [[ $(docker inspect -f '{{.State.Health.Status}}' $1) == "healthy" ]]; then
        echo "Container $1 is healthy"
        return 0
    else
        echo "Container $1 is not healthy"
        exit 1
    fi
}

# Try to install with hostname in the URL variable, if that fails then install with a self-signed certificate
install
if [[ $? -eq 0 ]]; then
    cleanup
else
    install-self-signed
fi