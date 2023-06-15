variable "ssh_password" { type = string }
variable "domain" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "packages"
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      packages:
        - python3
        - python3-pip
        - python3-venv
      EOF
  }

  part {
    filename     = "users"
    content_type = "text/cloud-config"
    content      = <<-EOF
      users:
        - name: localadmin
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: [sudo, www-data]
          shell: /bin/bash
          lock_passwd: false
          passwd: ${var.ssh_password}
          ssh_authorized_keys:
            - ${data.local_file.ssh-pubkey.content}
        - name: wordpress
          groups: [www-data]
          shell: /bin/bash
          lock_passwd: false
      EOF
  }

  part {
    filename     = "write_files"
    content_type = "text/cloud-config"
    content      = <<-EOF
      write_files:
        - path: /etc/environment
          content: |
            DOMAIN=${var.domain}
          append: true
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
        - path: /home/wordpress/.ssh/config
          content: |
            Host 127.0.0.1 localhost
              StrictHostKeyChecking no

            Host github.com
              User git
              HostName github.com
              IdentityFile ~/.ssh/id_rsa
              StrictHostKeyChecking no
          owner: wordpress:wordpress
          permissions: '0600'
          defer: true
        - path: /opt/wp-deploy/install.sh
          content: |
            ${data.local_file.install_sh.content}
          owner: localadmin:localadmin
          permissions: '0777'
          encoding: base64
          defer: true
        - path: /home/localadmin/.ssh/id_rsa
          content: |
            ${data.local_file.github_anonymous.content}
          owner: localadmin:localadmin
          permissions: '0600'
          encoding: base64
          defer: true
        - path: /home/localadmin/.ssh/id_rsa.pub
          content: |
            ${data.local_file.github_anonymous_pub.content}
          owner: localadmin:localadmin
          permissions: '0644'
          defer: true
        - path: /home/wordpress/.ssh/authorized_keys
          content: |
            ${data.local_file.ssh-pubkey.content}
          owner: wordpress:wordpress
          permissions: '0600'
          append: true
          defer: true
        - path: /etc/ssl.crt
          content: |
            ${data.local_file.ssl-cert.content}
          owner: root:root
          permissions: '0644'
          encoding: base64
          defer: true
        - path: /etc/ssl.key
          owner: root:root
          permissions: '0600'
          content: |
            ${data.local_file.ssl-key.content}
          encoding: base64
          defer: true
      EOF
  }

  part {
    filename     = "runcmd"
    content_type = "text/cloud-config"
    content      = <<-EOF
      runcmd:
        - cp /etc/skel/.bashrc /home/localadmin/.bashrc
        - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
        - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
        - chown localadmin:localadmin -R /home/localadmin/
        - sudo su - localadmin -c "bash /opt/wp-deploy/install.sh"
        - systemctl restart ssh
      EOF
  }
}
