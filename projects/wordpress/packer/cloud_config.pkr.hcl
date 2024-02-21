variable "hashed_passwd" { type = string }
variable "dns_username" { type = string }
variable "dns_password" { type = string }
variable "ssh_pubkey" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config = <<EOF
    #cloud-config
    packages:
      - docker
      - docker-compose-v2
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
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
  EOF
}
