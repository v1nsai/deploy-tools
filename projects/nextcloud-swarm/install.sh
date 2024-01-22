#!/bin/bash

set -e

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
    cat <<-EOF
        services: 
            nginx:
                container_name: nginx
                image: nginx:latest
                ports:
                - 80:80
                - 443:443
                restart: unless-stopped
                volumes:
                - /config/nginx/templates:/etc/nginx/templates/
                - /config/nginx/site-confs:/etc/nginx/conf.d/
                - /config/nginx/ssl:/etc/nginx/ssl/
EOF > /opt/deploy/proxy.yaml

    docker stack rm nginx || true
    docker stack deploy -c /opt/deploy/swag.yaml swag
    docker stack deploy -c /opt/deploy/compose.yaml nextcloud
    while [[ ! -f /config/etc/letsencrypt/live/${URL}/fullchain.pem ]] && [[ ! -f /config/etc/letsencrypt/live/${URL}/privkey.pem ]]; do
        echo "Waiting for SSL certs and keys to be generated..."
        sleep 10
    done
    rm -f /config/nginx/ssl/privkey.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/fullchain.pem /config/nginx/ssl/fullchain.pem
    ln -s /etc/letsencrypt/live/$URL/privkey.pem /config/nginx/ssl/privkey.pem
    docker service update swag
}

install-self-signed() {
    echo "Creating a self-signed certificate..."
    URL=$(curl -s ifconfig.io)
    mkdir -p /config/nginx/ssl
    openssl req -newkey rsa:2048 -nodes -keyout /config/nginx/ssl/privkey.pem -x509 -days 365 -out /config/nginx/ssl/fullchain.pem -subj "/CN=$URL/emailAddress=support@techig.com/C=US"

    echo "Your site will be available at https://$URL"
    rm -rf /config/nginx/site-confs/nextcloud.conf
    envsubst '$URL' < /config/nginx/conf-templates/nextcloud.conf.template > /config/nginx/site-confs/nextcloud.conf

    # docker compose -f /opt/deploy/docker-compose.yaml --profile selfsigned up -d
    docker stack deploy -c /opt/deploy/nginx.yaml nginx
    docker stack deploy -c /opt/deploy/docker-compose.yaml nextcloud
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

nextcloud-config() {
    if [[ -f .env ]]; then
        echo "Config file already exists, skipping..."
        return 0
    fi

    echo "Configuring .env..."
    curl -o .env https://raw.githubusercontent.com/nextcloud/all-in-one/main/manual-install/sample.conf

    NC_DOMAIN="nextcloud.techig.com"
    CLAMAV_ENABLED="yes"          
    COLLABORA_ENABLED="yes"
    FULLTEXTSEARCH_ENABLED="no"
    IMAGINARY_ENABLED="yes"
    ONLYOFFICE_ENABLED="no"
    TALK_ENABLED="yes"
    TALK_RECORDING_ENABLED="no"

    APACHE_IP_BINDING="127.0.0.1" 
    APACHE_MAX_SIZE=10737418240
    APACHE_PORT=11000

    sed -i "s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/FULLTEXTSEARCH_PASSWORD=.*/FULLTEXTSEARCH_PASSWORD='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/NC_DOMAIN=.*/NC_DOMAIN=$NC_DOMAIN/g" .env
    sed -i "s/NEXTCLOUD_PASSWORD=.*/NEXTCLOUD_PASSWORD='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/ONLYOFFICE_SECRET=.*/ONLYOFFICE_SECRET='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/RECORDING_SECRET=.*/RECORDING_SECRET='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/REDIS_PASSWORD=.*/REDIS_PASSWORD='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/SIGNALING_SECRET=.*/SIGNALING_SECRET='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/TALK_INTERNAL_SECRET=.*/TALK_INTERNAL_SECRET='"$(openssl rand -base64 32)"'/g" .env
    sed -i "s/TIMEZONE=.*/TIMEZONE=$TIMEZONE/g" .env
    sed -i "s/TURN_SECRET=.*/TURN_SECRET='"$(openssl rand -base64 32)"'/g" .env

    sed -i "s/CLAMAV_ENABLED=.*/CLAMAV_ENABLED=$CLAMAV_ENABLED/g" .env
    sed -i "s/COLLABORA_ENABLED=.*/COLLABORA_ENABLED=$COLLABORA_ENABLED/g" .env
    sed -i "s/FULLTEXTSEARCH_ENABLED=.*/FULLTEXTSEARCH_ENABLED=$FULLTEXTSEARCH_ENABLED/g" .env
    sed -i "s/IMAGINARY_ENABLED=.*/IMAGINARY_ENABLED=$IMAGINARY_ENABLED/g" .env
    sed -i "s/ONLYOFFICE_ENABLED=.*/ONLYOFFICE_ENABLED=$ONLYOFFICE_ENABLED/g" .env
    sed -i "s/TALK_ENABLED=.*/TALK_ENABLED=$TALK_ENABLED/g" .env
    sed -i "s/TALK_RECORDING_ENABLED=.*/TALK_RECORDING_ENABLED=$TALK_RECORDING_ENABLED/g" .env

    sed -i "s/APACHE_IP_BINDING=.*/APACHE_IP_BINDING=$APACHE_IP_BINDING/g" .env
    sed -i "s/APACHE_MAX_SIZE=.*/APACHE_MAX_SIZE=$APACHE_MAX_SIZE/g" .env
    sed -i "s/APACHE_PORT=.*/APACHE_PORT=$APACHE_PORT/g" .env

    echo "Configuring compose.yaml..."
    curl https://raw.githubusercontent.com/nextcloud/all-in-one/main/manual-install/latest.yml | yq -o json | jq 'del(.services[] | .profiles)' | yq -P > compose.yaml
}

cd /opt/deploy
docker swarm init --advertise-addr $(hostname -I | awk '{ print $1 }') || true
nextcloud-config
install
if [[ $? -eq 0 ]]; then
    cleanup
else
    install-self-signed
fi
