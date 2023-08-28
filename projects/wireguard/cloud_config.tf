variable "domain" { type = string }
variable "ssl_provisioner" { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_compose  = file("${path.cwd}/projects/wordpress/docker/docker.sh")
  ssh_key         = file(pathexpand("~/.ssh/techig-site"))
  ssh_pubkey      = file(pathexpand("~/.ssh/techig-site.pub"))

  cloud_config    = <<-EOF
    #cloud-config
    packages:
      - python3
      - python3-pip
      - python3-virtualenv
      - net-tools
      - jq
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
          - ${local.ssh_pubkey}
    write_files:
      - path: /etc/environment
        content: |
          WG_HOST=$(curl ifconfig.me)
          PASSWORD="jonk9ym.;lkj;lkj"
        append: true
      - path: /opt/wp-deploy/docker.sh
        permissions: '0755'
        content: |
          ${indent(6, local.docker_compose)}
        owner: localadmin:localadmin
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.profile
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile
  EOF
}
