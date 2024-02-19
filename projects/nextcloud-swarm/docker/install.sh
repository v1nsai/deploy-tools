#!/bin/bash

set -e
/opt/deploy/proxy.sh

nextcloud-config() {
    echo "Configuring .env..."
    curl -o .env https://raw.githubusercontent.com/nextcloud/all-in-one/main/manual-install/sample.conf

    if [[ -z "$URL" ]]; then
        NC_DOMAIN=$(curl ifconfig.io)
    else
        NC_DOMAIN=$URL
    fi
    CLAMAV_ENABLED="yes"          
    COLLABORA_ENABLED="yes"
    FULLTEXTSEARCH_ENABLED="no"
    IMAGINARY_ENABLED="yes"
    ONLYOFFICE_ENABLED="no"
    TALK_ENABLED="yes"
    TALK_RECORDING_ENABLED="no"
    UPDATE_NEXTCLOUD_APPS="yes"

    APACHE_IP_BINDING="127.0.0.1" 
    APACHE_MAX_SIZE=10737418240
    APACHE_PORT=11000

    TIMEZONE="America\/New_York"

    sed -i "s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/FULLTEXTSEARCH_PASSWORD=.*/FULLTEXTSEARCH_PASSWORD=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/NC_DOMAIN=.*/NC_DOMAIN=$NC_DOMAIN/g" .env
    sed -i "s/NEXTCLOUD_PASSWORD=.*/NEXTCLOUD_PASSWORD=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/ONLYOFFICE_SECRET=.*/ONLYOFFICE_SECRET=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/RECORDING_SECRET=.*/RECORDING_SECRET=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/REDIS_PASSWORD=.*/REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/SIGNALING_SECRET=.*/SIGNALING_SECRET=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/TALK_INTERNAL_SECRET=.*/TALK_INTERNAL_SECRET=$(openssl rand -base64 32 | tr -d '/\&')/g" .env
    sed -i "s/TIMEZONE=.*/TIMEZONE=$TIMEZONE/g" .env
    sed -i "s/TURN_SECRET=.*/TURN_SECRET=$(openssl rand -base64 32 | tr -d '/\&')/g" .env

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

    sed -i "s/UPDATE_NEXTCLOUD_APPS=.*/UPDATE_NEXTCLOUD_APPS=$UPDATE_NEXTCLOUD_APPS/g" .env
    sed -i "s/TIMEZONE=.*/TIMEZONE=$TIMEZONE/g" .env

    echo "Configuring Nextcloud compose.yaml..."
    curl https://raw.githubusercontent.com/nextcloud/all-in-one/main/manual-install/latest.yml | \
        yq -o json | \
        jq 'del(.services[] | .profiles)' | \
        jq 'del(.services[] | .depends_on)' | \
        jq 'del(.networks."nextcloud-aio".enable_ipv6)' | \
        yq -P | \
        tee nextcloud.yaml.template
    
    # add "export " to each line in .env so envsubst will work
    sed -i 's/^/export /' .env
    sed -i '/^export $/d' .env
    source .env
    envsubst < nextcloud.yaml.template > nextcloud.yaml

    # wrap quotes around shm_sizes to stop docker from complaining
    SHM_SIZE=$(yq eval '.services."nextcloud-aio-database".shm_size' nextcloud.yaml)
    yq eval '.services."nextcloud-aio-database".shm_size = "'"${SHM_SIZE}"'"' -i nextcloud.yaml
    SHM_SIZE=$(yq eval '.services."nextcloud-aio-talk-recording".shm_size' nextcloud.yaml)
    yq eval '.services."nextcloud-aio-talk-recording".shm_size = "'"${SHM_SIZE}"'"' -i nextcloud.yaml

    # overlay network for swarm
    yq eval '.networks."nextcloud-aio".driver = "overlay"' -i nextcloud.yaml
}

cd /opt/deploy
docker swarm init --advertise-addr $(hostname -I | awk '{ print $1 }') || true
nextcloud-config