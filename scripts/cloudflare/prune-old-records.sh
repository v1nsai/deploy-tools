#!/bin/bash

set -e
source auth/cloudflare.env

records=$(scripts/cloudflare/list-records.sh)
echo $records | jq '.result[] | select( .comment | contains("Temporary"))'
exit
echo "$records" | jq '.result[] | select( .comment | contains("Temporary"))' | while read -r record; do
    created_on=$(echo "$record" | jq -r '.created_on')
    now=$(date -u +"%Y-%m-%dT%H:%M:%S.%N")"Z"
    start_seconds=$(date -u -d "${created_on%Z}" +%s)
    end_seconds=$(date -u -d "${now%Z}" +%s)
    seconds_diff=$((end_seconds - start_seconds))
    days_diff=$((seconds_diff / 86400))
    echo "$record"
    echo "$days_diff"
    # if [[ $days_diff -gt 30 ]]; then
    #     echo "Deleting record $record"
    #     scripts/cloudflare/delete-record.sh $(echo "$record" | jq -r '.name')
    # fi
done

echo 