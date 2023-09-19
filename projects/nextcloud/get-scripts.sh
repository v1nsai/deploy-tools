#!/bin/bash
## Clones the scripts folder from the TechIG-official/wordpress repository.  You will need to have access to the repo and have ssh set up with github

set -e

echo "If you are updating, don't forget to stash or commit your changes before running this script or they will be overwritten!"
read -p "Press enter to continue"

cd "$(dirname "$0")"
mkdir -p docker/prometheus-grafana
cd docker/prometheus-grafana
git init
git remote add --fetch origin git@github.com:docker/awesome-compose.git || echo "Remote already exists, skipping..."
git config core.sparseCheckout true
echo "prometheus-grafana/" >> .git/info/sparse-checkout
git pull origin master
mv scripts/* . || echo "No files to move, skipping..."
rm -rf scripts
