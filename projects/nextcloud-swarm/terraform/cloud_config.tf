variable "hashed_passwd" { type = string }

locals {
  cloud_config = <<-EOF
    #cloud-config
    packages:
      - docker
      - docker-compose
      - net-tools
      - nnn
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
          ${file("${path.cwd}/projects/nextcloud-swarm/install.sh")}
        permissions: '0755'
      - path: /config/nginx/site-confs/default.conf
        content: |
          ${file("${path.cwd}/projects/nextcloud-swarm/docker/nginx/site-confs/default.conf")}
        permissions: '0644'
      - path: /config/nginx/conf-templates/nextcloud.conf.template
        content: |
          ${file("${path.cwd}/projects/nextcloud-swarm/docker/nginx/conf-templates/nextcloud.conf.template")}
        permissions: '0644'
      - path: 
  EOF
}
