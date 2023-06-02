#!/bin/bash

template_file="projects/wordpress/cloud-init.tf"

# Find the line number containing "lemp-install.sh"
line_number=$(grep -n '\- path: .*lemp-install.sh' "$template_file" | cut -d ":" -f 1)

if [ -z "$line_number" ]; then
  echo "Line containing 'lemp-install.sh' not found in the template file."
  exit 1
fi

# Find the line number of the first line after "lemp-install.sh" that contains "content: "
next_line_number=$(awk "NR>$line_number && /content: / {print NR; exit}" "$template_file")

if [ -z "$next_line_number" ]; then
  echo "Line containing 'content: ' not found after 'lemp-install.sh' in the template file."
  exit 1
fi

# Replace the content after the colon and single space with a new value
new_value=$(cat projects/wordpress/lemp-install.sh | base64 -w 0)
sed -i "${next_line_number}s/: .*/: ${new_value}/" "$template_file"

echo "Replacement complete. Updated template:"
cat "$template_file"
