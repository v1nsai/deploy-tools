locals {
  cloud-init = <<EOF
#cloud-config
package_update: true
packages:
  - python3
  - python3-pip
  - python3-venv
ssh_pwauth: true
users:
  - name: localadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
    ssh_authorized_keys:
      - ${data.local_file.ssh-pubkey.content}
    ssh_keys:
      rsa_private: |
        ${indent(8, data.local_sensitive_file.private-key.content)}
      rsa_public: |
        ${indent(8, data.local_file.ssh-pubkey.content)}
write_files:
  - path: /home/localadmin/.ssh/devbox
    content: |
      ${indent(6, data.local_sensitive_file.private-key.content)}
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
        IdentitiesOnly yes
    owner: localadmin:localadmin
    permissions: '0600'
    append: true
    defer: true
  - path: /home/localadmin/auth/alterncloud.env
    content: |
      ${indent(6, data.local_sensitive_file.alterncloud-env.content)}
    owner: localadmin:localadmin
    defer: true
  - path: /etc/crontab
    content: 30 3    * * *   root    /usr/sbin/shutdown -h
    append: true
    defer: true
runcmd:
- cp /etc/skel/.bashrc /home/localadmin/.bashrc
- sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
- cp -f /home/localadmin/.bashrc /home/localadmin/.profile
- cp -f /home/localadmin/.ssh/config /root/.ssh/config
- chown localadmin:localadmin -R /home/localadmin/
- systemctl restart ssh
  EOF
}