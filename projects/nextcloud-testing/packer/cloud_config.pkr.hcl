variable "hashed_passwd" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/nextcloud-testing.pub"))

  cloud_config = <<EOF
    #cloud-config
    packages:
      - python3
      - python3-pip
      - python3-virtualenv
      - net-tools
      - jq
      - docker
      - docker-compose-v2
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
          - ${local.ssh_pubkey}
    write_files:
      - path: /etc/environment
        content: |
          URL=
        append: true
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
  EOF
}
