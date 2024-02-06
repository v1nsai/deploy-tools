variable "hashed_passwd"     { type = string }
variable "openproject_email" { type = string }
variable "openproject_host"   { type = string }

locals {
  cloud_config = <<-EOF
    #cloud-config
    packages:
      - nnn
      - net-tools
      - docker
      - docker-compose
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
          - ${file(pathexpand("~/.ssh/openproject.pub"))}
    write_files:
      - path: /etc/environment
        content: |
          OPENPROJECT_ADMIN__EMAIL="${var.openproject_email}"
          OPENPROJECT_HOST__NAME="${var.openproject_host}"
        append: true
      - path: /opt/deploy/install.sh
        permissions: '0755'
        content: |
          ${indent(6, file("${path.cwd}/projects/openproject/install.sh"))}
      - path: /opt/deploy/docker-compose.yml
        permissions: '0644'
        content: |
          ${indent(6, file("${path.cwd}/projects/openproject/docker-compose.yml"))}
      - path: /opt/deploy/proxy-docker-compose.yml
        permissions: '0644'
        content: |
          ${indent(6, file("${path.cwd}/projects/openproject/proxy-docker-compose.yml"))}
      - path: /etc/nginx/templates/openproject.conf.template
        permissions: '0644'
        content: |
          ${indent(6, file("${path.cwd}/projects/openproject/openproject.conf.template"))}
      - path: /etc/nginx/conf/default.conf
        permissions: '0644'
        content: |
          ${indent(6, file("${path.cwd}/projects/openproject/default.conf"))}
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.bashrc
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
      - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
      - /opt/deploy/install.sh > /var/log/install.log 2>&1
      - chown localadmin:localadmin -R /home/localadmin/
      - chown localadmin:localadmin -R /opt/deploy/
  EOF
}
