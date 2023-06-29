#!/bin/bash

set -e

# Create base64 files
base64 -w 0 ~/.ssh/github_anonymous > ~/.ssh/github_anonymous.base64
base64 -w 0 projects/wordpress/install.sh > projects/wordpress/install.sh.base64
base64 -w 0 auth/ssl/doctor-ew.com.crt > auth/ssl.crt.base64
base64 -w 0 auth/ssl/doctor-ew.com.key > auth/ssl.key.base64
base64 -w 0 projects/wordpress/ansible/inventory.yml > projects/wordpress/ansible/inventory.yml.base64
base64 -w 0 projects/wordpress/ansible/deploy.yml > projects/wordpress/ansible/deploy.yml.base64