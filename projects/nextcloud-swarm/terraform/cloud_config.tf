variable "hashed_passwd" { type = string }

locals {
  cloud_config = <<-EOF
    #cloud-config
    packages:
      - docker
      - docker-compose-v2
      - net-tools
      - nnn
      - jq
    package_update: true
    ssh_pwauth: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo, docker
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${file(pathexpand("~/.ssh/nextcloud.pub"))}
    write_files:
      - path: /etc/environment
        content: |
          URL=nextcloud-testing.techig.com
          STAGING=true
        append: true
      - path: /opt/deploy/install.sh
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud-swarm/install.sh"))}
        permissions: '0755'
      - path: /config/nginx/site-confs/default.conf
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud-swarm/docker/nginx/site-confs/default.conf"))}
        permissions: '0644'
      - path: /config/nginx/conf-templates/nextcloud.conf.template
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud-swarm/docker/nginx/conf-templates/nextcloud.conf.template"))}
        permissions: '0644'
      - path: /opt/deploy/nginx.yaml
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud-swarm/docker/nginx.yaml"))}
        permissions: '0644'
      - path: /opt/deploy/swag.yaml
        content: |
          ${indent(6, file("${path.cwd}/projects/nextcloud-swarm/docker/swag.yaml"))}
        permissions: '0644'
    runcmd:
      - wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
      - /opt/deploy/install.sh > /var/log/deploy.log 2>&1 &
  EOF
}
