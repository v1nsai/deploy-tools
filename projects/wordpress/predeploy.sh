#!/bin/bash

set -e 

rm -rf projects/wordpress/postdeploy.zip
zip -r projects/wordpress/postdeploy.zip auth/wordpress/pki projects/wordpress/lemp-install.sh projects/wordpress/nginx-domain

# function update_content_for_path() {
#   ## Find the first line number containing the search string
#   line_number=$(grep -n '\- path: .*'$1'.*' "$template_file" | cut -d ":" -f 1)
#   if [ -z "$line_number" ]; then
#     echo "Line containing '$1' not found in the template file."
#     exit 1
#   fi

#   ## Find the line number of the line containing "content: "
#   next_line_number=$(awk "NR>$line_number && /content: / {print NR; exit}" "$template_file")
#   if [ -z "$next_line_number" ]; then
#     echo "Line containing 'content: ' not found after '$1' in the template file."
#     exit 1
#   fi

#   # Replace the content
#   new_value=$(cat projects/wordpress/$1 | base64 -w 0)
#   sed -i "${next_line_number}{N;s/.*/          content: |\n            ${new_value}/}" "$template_file"
# }

# # setup
# echo "Updating scripts in cloud-init.tf..."
# template_file="projects/wordpress/cloud-init.tf"

# Write files
# update_content_for_path "lemp-install.sh"
# update_content_for_path "nginx-domain"