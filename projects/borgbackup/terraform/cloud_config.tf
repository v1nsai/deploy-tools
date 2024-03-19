variable "hashed_passwd" { type = string }

locals {
  cloud_config    = <<-EOF
    #cloud-config
    packages:
      - nnn
      - net-tools
      - borgbackup
      - sshfs
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo, docker
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${file(pathexpand("~/.ssh/borgbackup.pub"))}
    write_files:
      - path: /etc/environment
        content: |
          CERTRESOLVER=
        append: true
  EOF
}
