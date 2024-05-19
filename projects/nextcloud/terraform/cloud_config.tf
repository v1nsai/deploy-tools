variable "hashed_passwd" { type = string }
variable "URL" { type = string }

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
          URL=${var.URL}
        append: true
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
        append: true
      - path: /opt/deploy/proxy.sh
        permissions: '0755'
        content: |
          ${indent(10, file("${path.cwd}/projects/traefik/proxy.sh"))}
      - path: /opt/deploy/install.sh
        permissions: '0755'
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/docker/install.sh"))}
      - path: /opt/deploy/docker-compose.yaml
        permissions: '0755'
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/docker/docker-compose.yaml"))}
      - path: /etc/traefik/traefik.yaml
        permissions: '0644'
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/docker/traefik.yaml"))}
      - path: /etc/traefik/routes.yaml
        permissions: '0644'
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud/docker/routes.yaml"))}
  EOF
}
