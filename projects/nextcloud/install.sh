#!/bin/bash

install() {
    echo "Configuring SSL..."
    if [[ -z "$URL" ]]; then
        echo "URL variable not set, defaulting to self-signed certificate..."
        return 1
    fi
    URL=$(echo $URL | sed 's/https\?:\/\///g') # strip http(s):// from URL
    echo $URL    
    docker compose down traefik # in case this isn't the first reboot
    yq eval '.http.routers.router.tls.certResolver = "letsencrypt-prod"' -i /etc/traefik/routes.yaml
    docker compose up -d
}

install-self-signed() {
    echo "Creating a new domain and certificate..."
    # URL=$(curl -s ifconfig.io)
    source /opt/deploy/duckdns.env
    URL='nextcloud.local'
    docker compose down traefik
    yq eval '.http.routers.router.tls = {}' -i /etc/traefik/routes.yaml
    docker compose up -d
}

cleanup() {
    echo "Checking health status of containers..."
    sleep 30
    for container in "nextcloud-aio-mastercontainer" ; do
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

post-install() {
    echo "Configuring trusted proxies for Nextcloud..."
    while [[ $(docker ps --filter name=nextcloud-aio-nextcloud -q) == "" ]]; do
        echo "Waiting for user to finish initial Nextcloud setup..."
        sleep 10
    done
    subnet=$(docker network inspect nextcloud-aio --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}')
    subnet=$(echo $subnet | sed 's/\//\\\//g') # escape forward slashes in subnet
    docker run -it --rm --volume nextcloud_aio_nextcloud:/var/www/html:rw alpine sh -c "apk update && apk add perl && perl -0777 -pe \"s/('trusted_proxies' =>[\n\s]*array \()(.*)/\1\n    3 => '"$subnet"',    \2/s\" /var/www/html/config/config.php > /var/www/html/config/config.php.new && mv /var/www/html/config/config.php.new /var/www/html/config/config.php"
}

pre-install() {
    cd /opt/deploy
    COMPOSE_PROJECT_NAME=nextcloud

    echo "Installing dependencies..."
    wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
    mkdir -p /etc/traefik
    touch /etc/traefik/acme.json
    chmod 600 /etc/traefik/acme.json
}

pre-install -e || (echo "Failed to install dependencies, exiting..." && exit 1)
install -e && cleanup || (echo "Failed to install, exiting..." && exit 1) # install-self-signed -e ||
post-install -e || (echo "Failed to configure trusted proxies, exiting..." && exit 1)
cleanup -e || (echo "Failed to cleanup, exiting..." && exit 1)
