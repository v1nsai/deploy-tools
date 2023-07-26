#!/bin/bash

set -e

# Wait for cloud-init to finish
cloud-init status --wait

# Set variables and create working directory
DEVENV="production"
SERVERIP=$(curl -s http://whatismyip.akamai.com/)

# Generate a DNS record for the server
if [[ -z $DOMAIN ]]; then
    echo "ERROR - DOMAIN var must be set to either a valid domain name or 'dynamic' for a dynamic dns"
    exit 1
fi

if [[ $DOMAIN == "dynamic" ]]; then
    echo "Generating a dynamic DNS record for $SERVERIP..."
    DOMAIN=$(/opt/wp-deploy/create-temp-record.sh)
fi

# Install dependencies
curl -sL https://roots.io/trellis/cli/get | sudo bash
python3 -m pip install virtualenv ansible
# /home/localadmin/.local/bin/ansible-galaxy install kwoodson.yedit
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

# Create a new project
if [[ $SSL_PROVISIONER == "none" ]]; then
    trellis new --host $SERVERIP --name $SERVERIP $SERVERIP || echo "Trellis project already exists, continuing..."
    DOMAIN=$SERVERIP
else
    trellis new --host $DOMAIN --name $DOMAIN $DOMAIN || echo "Trellis project already exists, continuing..."\j
fi

# Configure users
yq -i '.web_user = "wordpress"' $DOMAIN/trellis/group_vars/all/users.yml
yq -i '.admin_user = "localadmin"' $DOMAIN/trellis/group_vars/all/users.yml

# Configure wordpress_sites
sed -i 's/example\.com/'$DOMAIN'/g' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
yq -i '.wordpress_sites."'$DOMAIN'".repo = "git@github.com:roots/bedrock.git"' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
sed -i '/repo_subtree_path/ s/.*//' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml

# SSL config
case $SSL_PROVISIONER in
    "letsencrypt")
        echo "Setting up letsencrypt..."
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = true' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.provider = "letsencrypt"' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
        ;;
    "manual")
        echo "Setting up manual SSL..."
        sed -i '/ssl:/,/letsencrypt/c\    ssl:\n      enabled: true\n      provider: manual\n      cert: /etc/ssl.crt\n      key: /etc/ssl.key' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml # TODO use yq to add new keys
        ;;
    "none")
        echo "Not setting up SSL."
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = false' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
        ;;
    *)
        echo "SSL_PROVISIONER not set, not setting up SSL."
        yq -i '.wordpress_sites."'$DOMAIN'".ssl.enabled = false' $DOMAIN/trellis/group_vars/$DEVENV/wordpress_sites.yml
    ;;
esac
echo "SSL_PROVISIONER set to $SSL_PROVISIONER"

# Configure hosts
sed -i 's/your_server_hostname/127.0.0.1/g' $DOMAIN/trellis/hosts/$DEVENV

# Add all pubkeys to the authorized_keys file for privileged and non privileged users
sudo cp -f /home/localadmin/.ssh/* /root/.ssh/
sudo mkdir -p /home/wordpress/.ssh
cat /home/localadmin/.ssh/*.pub | sudo tee -a /home/localadmin/.ssh/authorized_keys
chmod 600 /home/localadmin/.ssh/id_rsa
sudo cp /home/localadmin/.ssh/* /home/wordpress/.ssh/
sudo cp /home/localadmin/.ssh/* /root/.ssh/
sudo chown wordpress:wordpress -R /home/wordpress/.ssh/
sudo chown localadmin:localadmin -R /home/localadmin/.ssh/

# Configure access
if [[ -z $DOMAIN ]] ; then
    echo 'letsencrypt_contact_emails: [ "mail@'$DOMAIN'" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
else
    echo 'letsencrypt_contact_emails: [ "mail@yourdomain.com" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
fi
echo 'ip_whitelist: [ "0.0.0.0" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
echo 'ssh_client_ip_lookup: false' >> $DOMAIN/trellis/group_vars/all/main.yml

# Bug fixes
# Raise ipify timeout
sed -i 's/ipify_facts:/ipify_facts:\n        timeout: 60/g' $DOMAIN/trellis/roles/common/tasks/main.yml
# Raise the lock timeout for apt
sed -i '/- name: ensure ferm is installed/{N;s/$/\n    lock_timeout: 600/;}' $DOMAIN/trellis/roles/ferm/tasks/main.yml
# Force unattended-upgrades to run so it will quit interfering with trellis then remove the lock file that isn't getting removed for some reason
sudo unattended-upgrade -d
sudo rm /var/lib/dpkg/lock-frontend

# Provision and deploy to localhost
cd $DOMAIN/trellis
trellis provision $DEVENV
trellis deploy $DEVENV

# Disable root login and remove the install script from the crontab
echo -n "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
sudo crontab -r

echo "Installation complete. You can now access your site at https://$DOMAIN"