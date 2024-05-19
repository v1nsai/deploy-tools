variable "hashed_passwd" { type = string }

locals {
  cloud-init = <<EOF
    #cloud-config
    package_update: true
    packages:
      - python3
      - python3-pip
      - python3-venv
      - nnn
      - net-tools
    ssh_pwauth: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${data.local_file.ssh-pubkey.content}
    write_files:
      - path: /home/localadmin/.ssh/devbox
        content: |
          ${indent(8, data.local_sensitive_file.private-key.content)}
        owner: localadmin:localadmin
        permissions: '0600'
        defer: true
      - path: /home/localadmin/.ssh/devbox.pub
        content: |
          ${indent(8, data.local_file.ssh-pubkey.content)}
        owner: localadmin:localadmin
        permissions: '0600'
        defer: true
      - path: /etc/ssh/sshd_config
        content: |
          PermitRootLogin no
          PasswordAuthentication no
          PubkeyAuthentication yes
        append: true
      - path: /home/localadmin/.ssh/config
        content: |
          Host github.com
            Hostname github.com
            User git
            IdentityFile /home/localadmin/.ssh/devbox
        owner: localadmin:localadmin
        permissions: '0600'
        append: true
        defer: true
      - path: /home/localadmin/auth/openstack.env
        content: |
          ${indent(6, data.local_sensitive_file.openstack-env.content)}
        owner: localadmin:localadmin
        defer: true
    runcmd:
      - cp /etc/skel/.bashrc /home/localadmin/.bashrc
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
      - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
      - chown localadmin:localadmin -R /home/localadmin/
      - systemctl restart ssh
  EOF
}