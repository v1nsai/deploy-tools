#!/bin/bash

set -e
source auth/alterncloud.env

# Install LEMP stack
SCRIPT=$(base64 -w 0 projects/wordpress/lemp-install.sh)
yq e -i '(.write_files[] | select(.path == "/root/lemp-install.sh").content) = "'$SCRIPT'"' projects/wordpress/cloud-config.yaml