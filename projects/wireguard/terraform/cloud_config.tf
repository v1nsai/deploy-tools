variable "hashed_passwd" { type = string }

locals {
  cloud_config    = <<-EOF
    #cloud-config
    packages:
      - python3
      - python3-pip
      - python3-virtualenv
      - net-tools
      - nnn
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
          - ${indent(6, file("~/.ssh/wireguard.pub"))}
    write_files:
      - path: /etc/ssh/sshd_config
        permissions: '0644'
        content: |
          PermitRootLogin no
      - path: /home/localadmin/docker-compose.yml
        permissions: '0644'
        owner: localadmin
        content: |
          ${indent(6, file("${path.cwd}/projects/wireguard/docker/docker-compose.yml"))}
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.profile
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile
      - echo "WG_HOST=$(curl ifconfig.me)" >> /etc/environment
  EOF
}
