#!/bin/bash

# set -e
cd /opt/wp-deploy

echo "Generating /opt/deploy/.env file..."
if [ -f /opt/wp-deploy/.env ]; then
    source /opt/wp-deploy/.env
else
    echo "COMPOSE_PROJECT_NAME=wordpress" | tee -a .env
    echo "WORDPRESS_DB_PASSWORD='$(openssl rand -base64 32)'" | tee -a .env
    echo "MYSQL_PASSWORD='$(openssl rand -base64 32)'" | tee -a .env
    echo "COMPOSE_PROJECT_NAME=wordpress" | tee -a .env
    source .env
fi

install-plugins() {
    echo "Installing migration plugins..."
    echo "Waiting for user to complete WordPress setup..."
    while ! docker compose --profile selfsigned run --rm wp-cli wp --url="$URL" core is-installed --path="/var/www/html" --allow-root; do
        echo "Waiting for user to complete WordPress setup..."
        sleep 30
    done

    echo "Installing migration plugins..."
    docker cp /opt/wp-deploy/aio-wp-migration.zip wordpress:/var/www/html/wp-content/plugins/aio-wp-migration.zip
    docker cp /opt/wp-deploy/aio-wp-migration-unlimited.zip wordpress:/var/www/html/wp-content/plugins/aio-wp-migration-unlimited.zip
    plugin1_output=$(docker compose --profile selfsigned run --rm --user root wp-cli wp --url="$URL" plugin install --path="/var/www/html" /var/www/html/wp-content/plugins/aio-wp-migration.zip --activate --allow-root 2>&1)
    plugin2_output=$(docker compose --profile selfsigned run --rm --user root wp-cli wp --url="$URL" plugin install --path="/var/www/html" /var/www/html/wp-content/plugins/aio-wp-migration-unlimited.zip --activate --allow-root 2>&1)

    echo "Checking plugin installation for errors..."
    if [[ $plugin1_output == *"Destination folder already exists"* ]] && [[ "$plugin2_output" == *"Destination folder already exists"* ]]; then
        echo "Migration plugins already installed, continuing..."
        return 0
    elif [[ $plugin1_output == *"Success"* ]] && [[ "$plugin2_output" == *"Success"* ]]; then
        echo "Migration plugins installed successfully"
        return 0
    else
        echo "Error while installing migration plugins"
        echo "Plugin 1 output: $plugin1_output"
        echo "Plugin 2 output: $plugin2_output"
        return 1
    fi
}

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
    rm -rf /config/nginx/site-confs/wordpress.conf
    curl -o /config/nginx/site-confs/wordpress.conf https://raw.githubusercontent.com/linuxserver/reverse-proxy-confs/master/wordpress.subdomain.conf.sample
    sed -i "s/server_name.*$/server_name $URL;/g" /config/nginx/site-confs/wordpress.conf
    
    echo "Starting containers..."
    docker compose --profile selfsigned down nginx
    docker compose --profile swag -f /opt/wp-deploy/docker-compose.yaml up -d
    while [[ ! -f /config/etc/letsencrypt/live/${URL}/fullchain.pem ]] && [[ ! -f /config/etc/letsencrypt/live/${URL}/privkey.pem ]]; do
        echo "Waiting for SSL certs and keys to be generated..."
        sleep 10
    done
    rm -f /config/nginx/ssl/privkey.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/fullchain.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/privkey.pem /config/nginx/ssl/privkey.pem
    docker restart swag

    install-plugins
    if [[ "$?" -ne 0 ]]; then
        if install-plugins | grep -q "Destination folder already exists"; then
            docker compose --profile selfsigned exec -itu root wordpress chown -R www-data:www-data /var/www/html/wp-content
            return 0
        else
            echo "Error while installing plugins"
            return 1
        fi
    fi
}

install-self-signed() {
    echo "Creating a self-signed certificate..."
    URL=$(curl -s ifconfig.io)
    mkdir -p /config/nginx/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /config/nginx/ssl/privkey.pem -x509 -days 365 -out /config/nginx/ssl/fullchain.pem -subj "/CN=$URL/emailAddress=support@techig.com/C=US"

    echo "Your site will be available at https://$URL"
    rm -rf /config/nginx/site-confs/wordpress.conf
    envsubst '$URL' < /config/nginx/templates/wordpress.conf.template > /config/nginx/site-confs/wordpress.conf

    docker compose -f /opt/wp-deploy/docker-compose.yaml --profile selfsigned up -d
    install-plugins
    if [[ "$?" -ne 0 ]]; then
        if install-plugins | grep -q "Destination folder already exists"; then
            docker compose --profile selfsigned exec -itu root wordpress chown -R www-data:www-data /var/www/html/wp-content
            return 0
        else
            echo "Error while installing plugins"
            return 1
        fi
    fi
}

cleanup() {
    echo "Checking health status of containers..."
    sleep 30
    for container in "wordpress" "swag"; do
        healthcheck $container
    done
    sudo crontab -r
    echo "Deleting install files..."
    cd
    rm -rf /opt/wp-deploy
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