#!/bin/bash

# Load environment vars
./auth/refresh_token.sh

# POST to endpoint
curl -X POST -H "X-Auth-Token:$OS_TOKEN" -d @templates/single-server-template.json https://$OS_HEAT_HOST_URL:8004/v1/$OS_PROJECT_ID/stacks

# debug
echo "OS_TOKEN=$OS_TOKEN"
echo "OS_HOST_URL=$OS_HOST_URL"
echo "OS_PROJECT_ID=$OS_PROJECT_ID"