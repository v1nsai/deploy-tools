#!/bin/bash

set -e

# REMOVE FOR TESTING ONLY
helm -n nextcloud uninstall nextcloud || true

echo "Generating or retrieving credentials..."
NC_ADMIN_SECRET_NAME=nextcloud-admin
NC_NAMESPACE=nextcloud
MARIADB_SECRET_NAME=mariadb-passwords

if kubectl get secrets -n nextcloud | grep -q "$NC_ADMIN_SECRET_NAME"; then
    echo "Secret $NC_ADMIN_SECRET_NAME already exists"
else
    echo "Generating $NC_ADMIN_SECRET_NAME..."
    source projects/nextcloud/secrets.env
    NC_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic $NC_ADMIN_SECRET_NAME \
        --from-literal=nextcloud-password=$NC_PASSWORD \
        --from-literal=nextcloud-host=$NC_HOST \
        --from-literal=nextcloud-username=admin \
        --from-literal=nextcloud-token=$NC_PASSWORD \
        --from-literal=smtp-password=$SMTP_PASS \
        --from-literal=smtp-host=$SMTP_HOST \
        --from-literal=smtp-port=$SMTP_PORT \
        --from-literal=smtp-username=$SMTP_USER
fi

if kubectl get secrets -n nextcloud | grep -q $MARIADB_SECRET_NAME; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic mariadb-passwords \
        --from-literal=mariadb-password=$MARIADB_PASSWORD \
        --from-literal=password=$MARIADB_PASSWORD \
        --from-literal=mariadb-root-password=$MARIADB_ROOT_PASSWORD \
        --from-literal=mariadb-replication-password=$MARIADB_REPLICATION_PASSWORD
fi

# echo "Installing the repo and helm chart..."
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install nextcloud nextcloud/nextcloud \
    --debug \
    --namespace nextcloud \
    --set image.tag=fpm-alpine \
    # --set nextcloud.host=$NC_HOST \
    # --set nextcloud.existingSecret.enabled=true \
    # --set nextcloud.existingSecret.secretName=$NC_ADMIN_SECRET_NAME \
    # --set nextcloud.existingSecret.usernameKey=nextcloud-username \
    # --set nextcloud.existingSecret.passwordKey=nextcloud-password \
    # --set nextcloud.existingSecret.tokenKey=nextcloud-token \
    # --set nginx.enabled=true \
    # --set externalDatabase.enabled=true \
    # --set mariadb.enabled=true \
    # --set mariadb.auth.existingSecret=$MARIADB_SECRET_NAME \
    # --set mariadb.architecture=standalone \
    # --set service.type=NodePort \
    # --set service.nodePort=30080

# kubectl get secret --namespace default nextcloud -o jsonpath="{.data.nextcloud-password}" | base64 --decode
