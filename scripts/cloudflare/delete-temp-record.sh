#!/bin/bash

set -e
source auth/cloudflare.env

records=$(scripts/cloudflare/list-records.sh)
identifier=$(echo "$records" | jq -r '.result[] | select(.name | contains("'$1'")) | select(.tags[] | contains("temporary") | .id)')

if [[ "${#identifier[@]}" -gt 1 ]]; then
  echo "More than one record found for query $1, please be more specific"
  exit 1
fi

if [[ "${#identifier[@]}" -eq 0 ]]; then
  echo "No records found for query $1"
  exit 1
fi
exit
curl --request DELETE \
  --url https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$identifier \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $bearer_token"