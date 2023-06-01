#!/bin/bash

set -e
source auth/alterncloud.env

# add LEMP stack install script to cloud-config.yaml
encoded_content=$(base64 -w 0 projects/wordpress/lemp-install.sh)
yq e -i '.write_files[] |= select(.path == "/etc/lemp-install.sh") .content = "'$encoded_content'"' projects/wordpress/cloud-config.yaml

# add env variables to cloud-config.yaml
encoded_content="export PASS_MYSQL_ROOT=$mysql_root_password
export PASS_MYSQL_WP_USER=$mysql_wp_user_password
export PASS_WORDPRESS=$wordpress_password"
encoded_content=$(base64 -w 0 <<< "$encoded_content")
yq e -i '(.write_files[] | select(.path == "/etc/environment").content) = "'$encoded_content'"' projects/wordpress/cloud-config.yaml

# add ssh config to cloud-config.yaml
encoded_content="Port 1355
PermitRootLogin no
PasswordAuthentication yes"
encoded_content=$(base64 -w 0 <<< "$encoded_content")
yq e -i '(.write_files[] | select(.path == "/etc/sshd_config").content) = "'$encoded_content'"' projects/wordpress/cloud-config.yaml

# Update content of cloud-config.yaml in cloud-init.tf to trigger a rebuild if anything has changed
encoded_content=$(base64 -w 0 projects/wordpress/cloud-config.yaml)
sed -i '/filename\s*=\s*"cloud-config.yaml"/,/}/ s/content\s*=\s*base64decode("[^"]*")/content      = base64decode("'$encoded_content'")/' projects/wordpress/cloud-init.tf