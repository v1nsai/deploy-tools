#!/bin/bash

set -e
source auth/alterncloud.env

# LEMP stack script
CONTENT=$(base64 -w 0 projects/wordpress/lemp-install.sh)
yq e -i '(.write_files[] | select(.path == "/root/lemp-install.sh").content) = "'$CONTENT'"' projects/wordpress/cloud-config.yaml

# Alterncloud credentials
# CONTENT=$(base64 -w 0 auth/alterncloud.env)
# yq e -i '(.write_files[] | select(.path == "/root/auth/alterncloud.env").content) = "'$CONTENT'"' projects/wordpress/cloud-config.yaml