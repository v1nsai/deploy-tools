#!/bin/bash

set -e

USERDOMAIN=false
if [[ -v DOMAIN ]]; then
    echo "Setting DOMAIN..."
    USERDOMAIN=true
else
    echo "DOMAIN not set, defaulting to public IP"
    DOMAIN="$(curl -s http://whatismyip.akamai.com/)"
fi

sudo chmod 777 -R /opt/wp-deploy
cd /opt/wp-deploy

# Install dependencies
curl -sL https://roots.io/trellis/cli/get | sudo bash
python3 -m pip install virtualenv
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq

# Configure users
trellis new --name $DOMAIN --host $DOMAIN $DOMAIN
yq -i '.web_user = "wordpress"' $DOMAIN/trellis/group_vars/all/users.yml
yq -i '.admin_user = "localadmin"' $DOMAIN/trellis/group_vars/all/users.yml

# Configure wordpress_sites
sed -i 's/example\.com/'$DOMAIN'/g' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
yq -i '.wordpress_sites."'$DOMAIN'".repo = "git@github.com:roots/bedrock.git"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
sed -i '/repo_subtree_path/ s/.*//' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
## letsencrypt
# yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
# yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "letsencrypt"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
## User supplied certificate
## sed -i '/ssl:/,/letsencrypt/c\    ssl:\n      enabled: true\n      provider: manual\n      cert: ~/ssl/example.com.crt\n      key: ~/ssl/example.com.key' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
# yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
## Self signed certificate
yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "self-signed"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml

# Configure hosts
sed -i 's/your_server_hostname/127.0.0.1/g' $DOMAIN/trellis/hosts/production

# Configure ssh user
sudo cat /home/localadmin/.ssh/id_rsa.pub >> /home/localadmin/.ssh/authorized_keys
sudo cat /home/localadmin/.ssh/id_rsa.pub | sudo tee -a /home/wordpress/.ssh/authorized_keys
sudo cp -f /home/localadmin/.ssh/id_rsa /home/wordpress/.ssh/id_rsa
sudo cp -f /home/localadmin/.ssh/id_rsa.pub /home/wordpress/.ssh/id_rsa.pub
sudo chown -R wordpress:wordpress /home/wordpress/.ssh

# Configure access
if [ $USERDOMAIN = true] ; then
    echo 'letsencrypt_contact_emails: [ "mail@'$DOMAIN'" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
else
    echo 'letsencrypt_contact_emails: [ "mail@yourdomain.com" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
fi
echo 'ip_whitelist: [ "0.0.0.0" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
echo 'ssh_client_ip_lookup: false' >> $DOMAIN/trellis/group_vars/all/main.yml

# Raise ipify timeout
sed -i 's/ipify_facts:/ipify_facts:\n        timeout: 60/g' $DOMAIN/trellis/roles/common/tasks/main.yml

# Provision and deploy to localhost
cd $DOMAIN/trellis
trellis provision production
trellis deploy production