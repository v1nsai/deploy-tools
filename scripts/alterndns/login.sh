#!/bin/bash

set -e

POST_DATA="{
    \"username\": \"$OS_USERNAME\",
    \"password\": \"$OS_PASSWORD\"
}"

curl -i -X POST "https://cloud.alterncloud.com/api/login" \
   -H "Content-Type: application/json" \
   -d "${POST_DATA}"