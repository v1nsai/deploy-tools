#!/bin/bash

set -e

# algo config.cfg
CONTENT=$(base64 -w 0 projects/wireguard/config.cfg)
yq e -i '(.write_files[] | select(.path == "/opt/config.cfg").content) = "'$CONTENT'"' projects/wireguard/cloud-config.yaml