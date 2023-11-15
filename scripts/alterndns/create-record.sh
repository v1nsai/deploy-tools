#!/bin/bash

set -e

subdomain="$1"
domain="$2"
type="A"
ip=$(curl ifconfig.me)
source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $source_dir/.env
rm $source_dir/.env

echo "Getting token..."
token=$(curl -s 'https://cloud.alterncloud.com/api/login' \
    -d username="$dns_username" \
    -d password="$dns_password")
if echo "$token" | grep -q "error"; then
    echo "Encountered an error getting a token.  Error: $token"
else
    token=$(echo $token | jq -r '.token')
fi

echo "Getting zone info for $domain..."
zone=$(curl -sX GET "https://cloud.alterncloud.com/api/dns" \
    -H "Authorization: Bearer $token" | jq -r '.zones[] | select(.name == "'$domain'")')

# echo "Found record $zone"

echo "Setting service and zone ids..."
service_id=$(echo $zone | jq -r '.service_id')
zone_id=$(echo $zone | jq -r '.domain_id')

echo "Getting records for domain: $domain"
records=$(curl -sX GET "https://cloud.alterncloud.com/api/service/$service_id/dns/$zone_id" \
    -H "Authorization: Bearer $token" | jq -r '.records[]')

echo "Checking for existing record..."
existing_record=$(echo $records | jq 'select(.name == "'$subdomain'" and .type == "'$type'")')

if [[ -z "$existing_record" ]]; then
    echo "Creating new record..."
    POST_DATA="{
        \"name\": \"$subdomain.$domain\",
        \"ttl\": 3600,
        \"type\": \"A\",
        \"content\": \"$ip\"
    }"

    response=$(curl -sX POST "https://cloud.alterncloud.com/api/service/$service_id/dns/$zone_id/records" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "${POST_DATA}")
    success=$(echo $response | jq -r '.success')
else
    # echo "Editing already existing record..."
    # record_id=$(echo $existing_record | jq -r '.id')
    # if [[ -z "$record_id" ]]; then
    #     echo "Record id is empty, full error: $record_id"
    #     exit 1
    # fi

    # POST_DATA="{
    #     \"name\": \"$subdomain.$domain\",
    #     \"ttl\": 3600,
    #     \"type\": \"A\",
    #     \"content\": \"$ip\"
    # }"

    # response=$(curl -sX PUT "https://cloud.alterncloud.com/api/service/$service_id/dns/$zone_id/records/$record_id" \
    #     -H "Authorization: Bearer $token" \
    #     -H "Content-Type: application/json" \
    #     -d "${POST_DATA}")
    # success=$(echo $response | jq -r '.success')
    response="ERROR: subdomain already exists!"
    echo $response
    exit 1
fi

if [[ "$success" == "true" ]]; then
    echo "Record created/updated successfully!"
else
    if [[ "$response" == *"Contents are identical"* ]]; then
        echo "Records are identical, skipping edit..."
    else
        echo "Something went wrong, full response: $response"
        exit 1
    fi
fi
echo "Done!"
rm -- "$0"