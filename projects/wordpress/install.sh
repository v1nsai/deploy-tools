#!/bin/bash

set -e

USERDOMAIN=false
if [[ $DOMAIN ]]; then
    echo "Setting DOMAIN..."
    USERDOMAIN=true
else
    echo "DOMAIN not set, defaulting to public IP"
    DOMAIN="$(curl -s http://whatismyip.akamai.com/)"
fi

sudo mkdir -p /opt/wp-deploy
sudo chown -R localadmin:localadmin /opt/wp-deploy
cd /opt/wp-deploy
# sudo apt update
# sudo apt install -y python3 python3-pip python3-venv
# sleep 60

# Install dependencies
curl -sL https://roots.io/trellis/cli/get | sudo bash
python3 -m pip install virtualenv ansible
# /home/localadmin/.local/bin/ansible-galaxy install kwoodson.yedit
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq

# Configure users
trellis new --name $DOMAIN --host $DOMAIN $DOMAIN || echo "Domain already exists, skipping new website creation"
yq -i '.web_user = "wordpress"' $DOMAIN/trellis/group_vars/all/users.yml
yq -i '.admin_user = "localadmin"' $DOMAIN/trellis/group_vars/all/users.yml

# Configure wordpress_sites
sed -i 's/example\.com/'$DOMAIN'/g' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
yq -i '.wordpress_sites."'$DOMAIN'".repo = "git@github.com:roots/bedrock.git"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
sed -i '/repo_subtree_path/ s/.*//' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml

# SSL config
case $SSL_PROVISIONER in
    "letsencrypt")
        echo "Setting up letsencrypt..."
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "letsencrypt"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        ;;
    "manual")
        echo "Setting up manual SSL..."
        sed -i '/ssl:/,/letsencrypt/c\    ssl:\n      enabled: true\n      provider: manual\n      cert: /etc/ssl.crt\n      key: /etc/ssl.key' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        ;;
    "self-signed")
        echo "Setting up self-signed SSL..."
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "self-signed"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        ;;
    *)
        echo "SSL_PROVISIONER not set, defaulting to self-signed"
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "self-signed"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
    ;;
esac

# Configure hosts
sed -i 's/your_server_hostname/127.0.0.1/g' $DOMAIN/trellis/hosts/production

# Add all pubkeys to the authorized_keys file for privileged and non privileged users
# rm -rf /home/localadmin/.ssh/id_rsa*
# sudo ssh-keygen -t rsa -f /root/.ssh/id_rsa -P "" -b 4096
sudo cp -f /home/localadmin/.ssh/* /root/.ssh/
sudo mkdir -p /home/wordpress/.ssh
cat /home/localadmin/.ssh/*.pub | sudo tee -a /home/localadmin/.ssh/authorized_keys
chmod 600 /home/localadmin/.ssh/id_rsa
sudo cp /home/localadmin/.ssh/* /home/wordpress/.ssh/
sudo cp /home/localadmin/.ssh/* /root/.ssh/
sudo chown wordpress:wordpress -R /home/wordpress/.ssh/
sudo chown localadmin:localadmin -R /home/localadmin/.ssh/

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

# Disable root login now that trellis has finished
echo -n "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config