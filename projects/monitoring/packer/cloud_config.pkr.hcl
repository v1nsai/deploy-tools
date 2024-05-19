variable "hashed_passwd" { type = string }
variable "dns_username" { type = string }
variable "dns_password" { type = string }
variable "ssh_pubkey" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/monitoring.pub"))

  cloud_config = <<EOF
    #cloud-config
    packages:
      - docker
      - docker-compose
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
        append: true
        content: |
          ChallengeResponseAuthentication no
          PasswordAuthentication no
          PermitRootLogin no
  EOF
}
