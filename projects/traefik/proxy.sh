#!/bin/bash

cd /opt/deploy
COMPOSE_PROJECT_NAME=wordpress
HEALTHCHECK_CONTAINERS=( "wordpress" )

install() {
    echo "Configuring SSL..."
    if [[ -z "$URL" ]]; then
        echo "URL variable not set, defaulting to self-signed certificate..."
        return 1
    fi
    export URL=$(echo $URL | sed 's/https\?:\/\///g') # strip http(s):// from URL
    echo "Your site will be available at https://$URL"
       
    docker compose down traefik # in case this isn't the first reboot
    yq eval '.http.routers.router.tls.certResolver = "'${CERTRESOLVER:-letsencrypt-prod}'"' -i /etc/traefik/routes.yaml
    docker compose up -d

    post-install -e
    cleanup
}

install-self-signed() {
    echo "Configuring self-signed certificate..."
    export URL=$(curl -s ifconfig.io)
    echo "Your site will be available at https://$URL"
    docker compose down traefik
    yq eval '.http.routers.router.tls = {}' -i /etc/traefik/routes.yaml
    docker compose up -d

    post-install -e
}

cleanup() {
    echo "Checking health status of containers..."
    for container in $HEALTHCHECK_CONTAINERS ; do
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

pre-install -e || (echo "Failed to install dependencies, exiting..." && exit 1)
install -e || install-self-signed -e || (echo "Failed to install, exiting..." && exit 1)