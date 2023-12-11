#!/bin/bash

set -e

# REMOVE FOR TESTING ONLY
helm uninstall nextcloud-helm || true

echo "Generating credentials..."
APP_HOST=nextcloud-test.techig.com
if [[ -z "$APP_PASSWORD" ]]; then
    APP_PASSWORD=$(openssl rand -base64 20)
else
    APP_PASSWORD=$(kubectl get secret --namespace default nextcloud-helm -o jsonpath="{.data.nextcloud-password}" | base64 --decode)
fi
if [[ -z "$MARIADB_PASSWORD" ]]; then
    MARIADB_PASSWORD=$(openssl rand -base64 20)
else
    MARIADB_PASSWORD=$(kubectl get secret --namespace default nextcloud-helm-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
fi
if [[ -z "$MARIADB_PASSWORD" ]]; then
    MARIADB_PASSWORD=$(openssl rand -base64 20)
else
    MARIADB_PASSWORD=$(kubectl get secret --namespace default nextcloud-helm-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
fi
if [[ $(kubectl get secrets | grep -q nextcloud-smtp) > 0 ]]; then
    source auth/smtp.env
    kubectl create secret generic nextcloud-smtp \
        --from-literal=SMTP_PASS=$SMTP_PASS \
        --from-literal=SMTP_HOST=$SMTP_HOST \
        --from-literal=SMTP_PORT=$SMTP_PORT \
        --from-literal=SMTP_USER=$SMTP_USER
else
    SMTP_PASS=$(kubectl get secret --namespace default nextcloud-smtp -o jsonpath="{.data.SMTP_PASS}" | base64 --decode)
    SMTP_HOST=$(kubectl get secret --namespace default nextcloud-smtp -o jsonpath="{.data.SMTP_HOST}" | base64 --decode)
    SMTP_PORT=$(kubectl get secret --namespace default nextcloud-smtp -o jsonpath="{.data.SMTP_PORT}" | base64 --decode)
    SMTP_USER=$(kubectl get secret --namespace default nextcloud-smtp -o jsonpath="{.data.SMTP_USER}" | base64 --decode)
fi

echo "Installing the repo and helm chart..."
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update

envsubst '$SMTP_PASS,$SMTP_HOST,$SMTP_PORT,$SMTP_USER,$MARIADB_PASSWORD,$APP_PASSWORD' < projects/nextcloud-helm/values.yaml.template > projects/nextcloud-helm/values.yaml
helm install -f projects/nextcloud-helm/values.yaml nextcloud-helm nextcloud/nextcloud

# kubectl get secret --namespace default nextcloud-helm -o jsonpath="{.data.nextcloud-password}" | base64 --decode

    # --set ingress.annotations.kubernetes.io/tls-acme=true \

# echo "Deploying..."
# helm install nextcloud-helm nextcloud/nextcloud \
#     --set nextcloud.password=$APP_PASSWORD \
#     --set nextcloud.host=$APP_HOST \
#     --set service.type=LoadBalancer \
#     --set ingress.enabled=true \
#     --set app.kubernetes.io/ingress.class=nginx \
#     --set app.kubernetes.io/tls-acme=true \
#     --set ingress.tls[0].secretName=nextcloud-tls \
#     --set ingress.tls[0].hosts[0]=$APP_HOST \
#     --set mariadb.enabled=true \
#     --set mariadb.auth.password=$MARIADB_PASSWORD