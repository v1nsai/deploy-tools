variable "hashed_passwd" { type = string }
variable "bearer_token" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/dashboards.pub"))

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
    runcmd:
      - cp -f /etc/skel/.bashrc .profile
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile
  EOF
}
