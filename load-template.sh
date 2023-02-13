#!/bin/bash

source .env
source account-202-openrc.sh

# curl -H "X-Auth-Token:$OS_TOKEN" https://vpc2-console.cloud.alterncloud.com:8004/v1/67c039e6447f40ac8a34cd898cc51bde/template_versions

curl -H "X-Auth-Token:$OS_TOKEN" "https://vpc2-console.cloud.alterncloud.com:8774/v2.1/$OS_PROJECT_ID/images"

# openstack --os-auth-url $OS_AUTH_URL --os-token $OS_TOKEN