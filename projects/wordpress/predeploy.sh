#!/bin/bash

set -e

# LEMP stack script
CONTENT=$(base64 -w 0 projects/wordpress/lemp-install.sh)
yq e -i '(.write_files[] | select(.path == "/root/lemp-install.sh").content) = "'$CONTENT'"' projects/wordpress/cloud-config.yaml