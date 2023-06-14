#!/bin/bash

set -e

# Install dependencies
curl -sL https://roots.io/trellis/cli/get | sudo bash
python3 -m pip install virtualenv
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq

# Configure users
trellis new --name $DOMAIN --host $DOMAIN $DOMAIN
yq -i '.web_user = \"wordpress\"' $DOMAIN/trellis/group_vars/all/users.yml
yq -i '.admin_user = \"localadmin\"' $DOMAIN/trellis/group_vars/all/users.yml

# Configure wordpress_sites
sed -i 's/example\.com/'$DOMAIN'/g' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
yq -i '.wordpress_sites.\"'$DOMAIN'\".repo = \"git@github.com:roots/bedrock.git\"' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml
# yq -i '.wordpress_sites.\"'$DOMAIN'\".ssl.enabled = true' $DOMAIN/trellis/group_vars/production/wordpress_sites.yml

# Configure hosts
sed -i 's/your_server_hostname/127.0.0.1/g' $DOMAIN/trellis/hosts/production

# Configure ssh user
ssh-keygen -b 2048 -f /home/localadmin/.ssh/id_rsa -P ''
ssh-keygen -f /home/localadmin/.ssh/id_rsa -y > /home/localadmin/.ssh/id_rsa.pub
cat /home/localadmin/.ssh/id_rsa.pub >> /home/localadmin/.ssh/authorized_keys

# Configure access
echo 'letsencrypt_contact_emails: [ \"admin@'$DOMAIN'\" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
echo 'ip_whitelist: [ \"0.0.0.0\" ]' >> $DOMAIN/trellis/group_vars/all/main.yml
echo 'ssh_client_ip_lookup: false' >> $DOMAIN/trellis/group_vars/all/main.yml

# Raise ipify timeout
sed -i 's/ipify_facts:/ipify_facts:\n        timeout: 60/g' $DOMAIN/trellis/roles/common/tasks/main.yml

# Provision and deploy to localhost
cd $DOMAIN/trellis
trellis provision production
trellis deploy production