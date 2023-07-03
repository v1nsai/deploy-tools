variable "hashed_passwd" { type = string }

locals {
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
package_update: false
write_files:
  - path: /etc/ssh/sshd_config
    content: |
      PermitRootLogin no
    append: true
  - path: /home/localadmin/.ssh/config
    content: |
      Host 127.0.0.1 localhost
        StrictHostKeyChecking no

      Host github.com
        User git
        HostName github.com
        IdentityFile ~/.ssh/id_rsa
        StrictHostKeyChecking no
    owner: localadmin:localadmin
    permissions: '0600'
    defer: true
  - path: /home/wordpress/.ssh/authorized_keys
    content: |
      ${local.ssh_pubkey}
    owner: wordpress:wordpress
    permissions: '0600'
    append: true
    defer: true
  - path: /etc/crontab
    content: |
      @reboot localadmin /opt/wp-deploy/install.sh

    append: true
    defer: true
EOF
}