#!/bin/sh

# Get OpenStack vars
source ../auth/.env

# output
cat <<EOF
{
    "user_name": "$OS_USERNAME",
    "tenant_name": "$OS_PROJECT_NAME",
    "password": "$OS_PASSWORD",
    "auth_url": "$OS_AUTH_URL",
    "region": "$OS_REGION_NAME"
}
EOF