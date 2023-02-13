#!/usr/bin/env bash

./account-202-openrc.sh

export OS_TOKEN=$(curl -D - -X POST $OS_AUTH_URL/auth/tokens?nocatalog -H "Content-Type: application/json" -d '{ "auth": { "identity": { "methods": ["password"],"password": {"user": {"domain": {"name": "'"$OS_USER_DOMAIN_NAME"'"},"name": "'"$OS_USERNAME"'", "password": "'"xsA|n%4E"'"} } }, "scope": { "project": { "domain": { "name": "'"$OS_PROJECT_DOMAIN_NAME"'" }, "name":  "'"$OS_PROJECT_NAME"'" } } }}' | awk -F "[ ',]+" '/x-subject-token:/{print $2}')
sed -i '' -e "s/export OS_TOKEN=.*/export OS_TOKEN=$OS_TOKEN/g" .env
echo $OS_TOKEN
# echo "export OS_TOKEN=$OS_TOKEN" > .env
# sed 's/x-subject-token: //g'
# grep -E ".*?\n(x-subject-token:\s)"