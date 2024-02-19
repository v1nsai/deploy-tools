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

pre-install() {
    echo "Installing dependencies..."
    wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
    mkdir -p /etc/traefik
    touch /etc/traefik/acme.json
    chmod 600 /etc/traefik/acme.json

    echo "Generating /opt/deploy/.env file..."
    if [ -f /opt/deploy/.env ]; then
        source /opt/deploy/.env
    else
        echo "COMPOSE_PROJECT_NAME=wordpress" | tee -a .env
        echo "WORDPRESS_DB_PASSWORD='$(openssl rand -base64 32)'" | tee -a .env 2>&1
        echo "MYSQL_PASSWORD='$(openssl rand -base64 32)'" | tee -a .env 2>&1
        echo "COMPOSE_PROJECT_NAME=wordpress" | tee -a .env 2>&1
        source .env
    fi
}

post-install() {
    echo "Waiting for user to complete WordPress setup..."
    while ! docker compose --profile selfsigned run --rm wp-cli wp --url="$URL" core is-installed --path="/var/www/html" --allow-root; do
        echo "Waiting for user to complete WordPress setup..."
        sleep 10
    done

    echo "Installing migration plugins..."
    plugin1_output=$(docker compose run --rm --user root wp-cli wp --url="$URL" plugin install --path="/var/www/html" /config/wordpress/plugins/aio-wp-migration.zip --activate --allow-root 2>&1)
    plugin2_output=$(docker compose run --rm --user root wp-cli wp --url="$URL" plugin install --path="/var/www/html" /config/wordpress/plugins/aio-wp-migration-unlimited.zip --activate --allow-root 2>&1)

    echo "Checking plugin installation for errors..."
    if [[ $plugin1_output == *"Destination folder already exists"* ]] && [[ "$plugin2_output" == *"Destination folder already exists"* ]]; then
        echo "Migration plugins already installed, continuing..."
        echo "Cleaning up migration plugins installation..."
        healthcheck wordpress
        docker compose exec -u root wordpress chown -R www-data:www-data /var/www/html/
        return 0
    elif [[ $plugin1_output == *"Success"* ]] && [[ "$plugin2_output" == *"Success"* ]]; then
        echo "Migration plugins installed successfully"
        echo "Cleaning up migration plugins installation..."
        healthcheck wordpress
        docker compose exec -u root wordpress chown -R www-data:www-data /var/www/html/
        return 0
    else
        echo "Error while installing migration plugins"
        echo "Plugin 1 output: $plugin1_output"
        echo "Plugin 2 output: $plugin2_output"
        return 1
    fi
}

pre-install -e || (echo "Failed to install dependencies, exiting..." && exit 1)
install -e || install-self-signed -e || (echo "Failed to install, exiting..." && exit 1)
