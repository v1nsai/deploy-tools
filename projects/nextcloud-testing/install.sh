#!/bin/bash

# set -e
cd /opt/nc-deploy

create-record() {
    # if URL contains .techig.com, then create a DNS entry for it
    if [[ "$URL" == *".techig.com" ]]; then
        split=(${URL//./ })
        subdomain="${split[0]}"
        domain="techig.com"
        URL="$subdomain.$domain"
        /opt/nc-deploy/create-record.sh "$subdomain" "$domain" &
    else
        echo "Not creating a DNS entry for $URL. Please be sure to create a DNS entry for $URL pointing to this server."
    fi
}

install() {
    echo "Setting up Nextcloud with SSL..."
    if [[ -z "$URL" ]]; then
        # echo "Please set the URL environment variable."
        # return 1
        URL="$(curl ifconfig.me)"
        install-self-signed
        return 0
    fi

    create-record # create a DNS record if needed
    echo "Your site will be available at https://$URL"

    # Use envsubst on the nginx template to create the nginx config
    mkdir -p /etc/swag/nginx/site-confs
    envsubst '$URL' < /opt/nc-deploy/default.conf.template > /etc/swag/nginx/site-confs/default.conf

    docker-compose up -d
}

install-self-signed() {
    sed -i 's/STAGING=false/STAGING=true/' /opt/nc-deploy/docker-compose.yml
    
    create-record # create a DNS record if needed
    echo "Your site will be available at https://$URL"
    
    # Use envsubst on the nginx template to create the nginx config
    mkdir -p /etc/swag/nginx/site-confs
    envsubst '$URL' < /opt/nc-deploy/default.conf.template > /etc/swag/nginx/site-confs/default.conf

    docker-compose up -d
}

install-no-ssl() {
    echo "Encountered an error, continuing installation without SSL..."
    docker-compose -f /opt/nc-deploy/docker-compose-no-ssl.yml up -d
}

cleanup() {
    sed -i '/bearer_token/d' /etc/environment
    sed -i '/dns_username/d' /etc/environment
    sed -i '/dns_password/d' /etc/environment
    sudo crontab -r
    chown localadmin -R /opt/nc-deploy
    cd
    rm -rf /opt/nc-deploy
    echo "Finished cleanup"
}

# Try to install with SSL, if it fails then install without SSL
install || install-self-signed || install-no-ssl || true
cleanup
# rm -- "$0"
