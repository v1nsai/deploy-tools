#!/usr/bin/env bash

[ -f .env ] && source '.env'
[ -f auth/.env ] && source 'auth/.env'

export OS_TOKEN=$(curl -D - -X POST $OS_AUTH_URL/auth/tokens?nocatalog -H "Content-Type: application/json" -d '{ "auth": { "identity": { "methods": ["password"],"password": {"user": {"domain": {"name": "'"$OS_USER_DOMAIN_NAME"'"},"name": "'"$OS_USERNAME"'", "password": "'"xsA|n%4E"'"} } }, "scope": { "project": { "domain": { "name": "'"$OS_PROJECT_DOMAIN_NAME"'" }, "name":  "'"$OS_PROJECT_NAME"'" } } }}' | awk -F "[ ',]+" '/x-subject-token:/{print $2}')

echo "$OS_TOKEN"