variable "hashed_passwd" { type = string }

locals {
  ssh_key    = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config = <<EOF
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
      - name: wordpress
        groups: [www-data]
        shell: /bin/bash
        lock_passwd: false
        ssh_pwauth: true
        passwd: ${var.hashed_passwd}
  EOF
}
