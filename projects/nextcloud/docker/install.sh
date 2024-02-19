#!/bin/bash

source /opt/deploy/proxy.sh
COMPOSE_PROJECT_NAME=nextcloud
HEALTHCHECK_CONTAINERS=( "nextcloud-aio-nextcloud" )
CERTSRESOLVER=letsencrypt-staging

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

    echo "Installing dependencies..."
    wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
    mkdir -p /etc/traefik
    touch /etc/traefik/acme.json
    chmod 600 /etc/traefik/acme.json
}

pre-install -e || (echo "Failed to install dependencies, exiting..." && exit 1)
install -e && cleanup || (echo "Failed to install, exiting..." && exit 1)
post-install -e || (echo "Failed to configure trusted proxies, exiting..." && exit 1)
# cleanup -e || (echo "Failed to cleanup, exiting..." && exit 1)
