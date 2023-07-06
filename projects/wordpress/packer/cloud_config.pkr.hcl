variable "hashed_passwd" { type = string }

locals {
  ssh_key              = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey           = file(pathexpand("~/.ssh/wordpress.pub"))
  ssh_pubkey_anonymous = file(pathexpand("~/.ssh/github_anonymous.pub"))

  cloud_config = <<EOF
#cloud-config
ssh_pwauth: true
users:
  # - name: root
  #   lock_passwd: false
  #   hashed_passwd: ${var.hashed_passwd}
  #   ssh_authorized_keys:
  #     - ${local.ssh_pubkey}
  - name: localadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
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
apt:
  preserve_sources_list: true
package_update: true
packages:
  - python3
  - python3-pip
  - python3-virtualenv
  - net-tools
EOF
}
