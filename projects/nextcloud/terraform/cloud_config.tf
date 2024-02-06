variable "hashed_passwd" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/nextcloud.pub"))

  cloud_config = <<EOF
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
          - ${local.ssh_pubkey}
    write_files:
      - path: /etc/environment
        content: |
          URL=test.techig.com
          STAGING=true
        append: true
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
      - path: /opt/deploy/docker-compose.yaml
        permissions: '0644'
        owner: localadmin
        defer: true
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/docker-compose.yaml"))}
      - path: /etc/traefik/traefik.yaml
        permissions: '0644'
        owner: localadmin
        defer: true
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/traefik.yaml"))}
      - path: /etc/traefik/routes.yaml
        permissions: '0644'
        owner: localadmin
        defer: true
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/routes.yaml"))}
      - path: /opt/deploy/install.sh
        permissions: '0755'
        owner: localadmin
        defer: true
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/install.sh"))}
    runcmd:
      - echo "/opt/deploy/install.sh > /var/log/install.log 2>&1" | crontab -
  EOF
}
