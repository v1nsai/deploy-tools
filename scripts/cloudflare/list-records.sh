#!/bin/bash

set -e
source auth/cloudflare.env

curl --request GET \
  --url https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $bearer_token"