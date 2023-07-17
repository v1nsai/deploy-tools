#!/bin/bash

set -e
source auth/cloudflare.env

# Create new subdomain and make sure it isn't already in use
function generate_subdomain() {
    new_subdomain="temp$RANDOM.doctor-ew.com"
    record_list=$(scripts/cloudflare/list-records.sh)
    existing_subdomain=$(echo "$record_list" | jq -r '.result[] | select(.name | contains("'$new_subdomain'"))')
    if [ -z "$existing_subdomain" ]; then
        echo -n "$new_subdomain"
    else
        echo "Subdomain $new_subdomain already exists, generating a new one"
        generate_subdomain
    fi
}

new_subdomain=$(generate_subdomain)
subdomain_ip=$(curl ifconfig.me)

curl --request POST \
  --url https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $bearer_token" \
  --data '{
  "content": "'$subdomain_ip'",
  "name": "'$new_subdomain'",
  "proxied": false,
  "type": "A",
  "comment": "Temporary subdomain for WordPress demoing"
  }'