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
          URL=
        append: true
      - path: /opt/deploy/install.sh
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud-swarm/docker/install.sh"))}
        permissions: '0755'
      - path: /opt/deploy/docker-compose.yaml
        content: |
          ${indent(10, file("${path.cwd}/projects/nextcloud-swarm/docker/docker-compose.yaml"))}
    runcmd:
      - wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
      - /opt/deploy/install.sh > /var/log/deploy.log 2>&1 &
  EOF
}
