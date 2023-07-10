variable "hashed_passwd" { type = string }

locals {
  ssh_pubkey   = file(pathexpand("~/.ssh/bmo.pub"))

  cloud_config = <<EOF
#cloud-config
ssh_pwauth: true
users:
  - name: doctor_ew
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: ${var.hashed_passwd}
    ssh_authorized_keys:
      - ${local.ssh_pubkey}
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
