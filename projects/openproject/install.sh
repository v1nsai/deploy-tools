#!/bin/bash

set -e

source /etc/environment
echo "Generating /opt/deploy/.env file..."
if [[ -f /opt/deploy/.env ]]; then
    source /opt/deploy/.env
fi
if [[ -z "$OPENPROJECT_HOST__NAME" ]]; then
    echo "Please enter the URL of your OpenProject instance (e.g. https://www.openproject.org):"
    read OPENPROJECT_HOST__NAME
    OPENPROJECT_HOST__NAME=$(echo $OPENPROJECT_HOST__NAME | sed 's/https\?:\/\///')
    echo "OPENPROJECT_HOST__NAME='$OPENPROJECT_HOST__NAME'" | tee -a /opt/deploy/.env
fi
if [[ -z "$OPENPROJECT_ADMIN__EMAIL" ]]; then
    echo "Please enter the email address of the OpenProject admin user:"
    read OPENPROJECT_ADMIN__EMAIL
    echo "OPENPROJECT_ADMIN__EMAIL='$OPENPROJECT_ADMIN__EMAIL'" | tee -a /opt/deploy/.env
fi
echo "OPENPROJECT_SECRET_KEY_BASE='$(openssl rand -base64 32)'" | tee -a /opt/deploy/.env
echo "OPENPROJECT_HTTPS='true'" | tee -a /opt/deploy/.env
echo "COMPOSE_PROJECT_NAME=openproject" | tee -a /opt/deploy/.env
source /opt/deploy/.env

echo "Starting OpenProject..."
docker compose -f /opt/deploy/docker-compose.yaml up -d
