variable "ssh_password"     { type = string }
variable "domain"           { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  ssh_pubkey      = file(pathexpand("~/.ssh/nextcloud.pub"))

  cloud_config = <<-EOF
    #cloud-config
    packages:
      - docker
      - docker-compose
      - net-tools
      - nnn
    package_update: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo, docker
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.ssh_password}
        ssh_authorized_keys:
          - ${local.ssh_pubkey}
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          SUBDOMAIN=nextcloud
          ONLY_SUBDOMAINS=true
          STAGING=false
        append: true
      - path: /home/localadmin/.ssh/config
        permissions: '0600'
        owner: localadmin:localadmin
        defer: true
        content: |
          Host github.com
            User git
            HostName github.com
            IdentityFile /home/localadmin/.ssh/homelab
      - path: /home/localadmin/.ssh/homelab
        defer: true
        permissions: '0600'
        owner: localadmin:localadmin
        content: |
          ${indent(6, file(pathexpand("~/.ssh/homelab")))}
      - path: /opt/nc-deploy/scripts/shutdown.sh
        defer: true
        permissions: '0755'
        content: |
          ${indent(6, local.shutdown_script)}
      - path: /opt/nc-deploy/scripts/sparse-checkout.sh
        permissions: '0755'
        defer: true
        content: |
          ${indent(6, file("${path.cwd}/scripts/sparse-checkout.sh"))}
      - path: /opt/nc-deploy/config/docker-compose.yaml
        permissions: '0644'
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud/docker/docker-compose.yaml"))}
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.profile
      - mkdir -p /opt/nc-deploy
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile
      - echo 'cd /opt/nc-deploy' | tee -a /home/localadmin/.profile
      - docker-compose -f /opt/nc-deploy/config/docker-compose.yaml up -d > /opt/nc-deploy/compose.log 2>&1
      - chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /opt/nc-deploy
  EOF
}

      # - ssh-keyscan github.com | tee -a /home/localadmin/.ssh/known_hosts
      # - /opt/nc-deploy/scripts/sparse-checkout.sh projects/nextcloud/docker /opt/nc-deploy/docker
      # - mv /opt/nc-deploy/docker/projects/nextcloud/docker/ /opt/nc-deploy/config/ && rm -rf /opt/nc-deploy/docker
