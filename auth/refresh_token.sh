#!/usr/bin/env bash

[ -f .env ] && export DOTENV=".env"
[ -f auth/.env ] && export DOTENV="auth/.env"
# export DOTENV='auth/.env'

source "$DOTENV"
echo "$DOTENV"

export OS_TOKEN=$(curl -D - -X POST $OS_AUTH_URL/auth/tokens?nocatalog -H "Content-Type: application/json" -d '{ "auth": { "identity": { "methods": ["password"],"password": {"user": {"domain": {"name": "'"$OS_USER_DOMAIN_NAME"'"},"name": "'"$OS_USERNAME"'", "password": "'"xsA|n%4E"'"} } }, "scope": { "project": { "domain": { "name": "'"$OS_PROJECT_DOMAIN_NAME"'" }, "name":  "'"$OS_PROJECT_NAME"'" } } }}') | awk -F "[ ',]+" '/x-subject-token:/{print $2}'

sed -i '' -e "s/export OS_TOKEN=.*/export OS_TOKEN=$OS_TOKEN/g" $DOTENV
echo "updated OS_TOKEN in $DOTENV"