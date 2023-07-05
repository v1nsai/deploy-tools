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
write_files:
  - path: /etc/ssh/sshd_config
    content: |
      PermitRootLogin no
    append: true
  # - path: /home/localadmin/.ssh/config
  #   content: |
  #     Host 127.0.0.1 localhost
  #       StrictHostKeyChecking no

  #     Host github.com
  #       User git
  #       HostName github.com
  #       IdentityFile ~/.ssh/id_rsa
  #       StrictHostKeyChecking no
  #   owner: localadmin:localadmin
  #   permissions: '0600'
  #   defer: true
  - path: /home/wordpress/.ssh/authorized_keys
    content: |
      ${local.ssh_pubkey_anonymous}
    owner: wordpress:wordpress
    permissions: '0600'
    append: true
    defer: true
EOF
}
