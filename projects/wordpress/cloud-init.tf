variable "mysql_root_password" { type = string }
variable "mysql_wp_user_password" { type = string }
variable "wordpress_username" { type = string }
variable "wordpress_password" { type = string }
variable "ssh_password" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "packages"
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      packages:
        - nginx
        - mariadb-server
        - php-fpm
        - php-mysql
        - php-curl
        - php-gd
        - php-intl
        - php-mbstring
        - php-soap
        - php-xml
        - php-xmlrpc
        - php-zip
      EOF
  }

  part {
    filename     = "users"
    content_type = "text/cloud-config"
    content      = <<-EOF
      users:
        - name: drew
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: [sudo, www-data]
          shell: /bin/bash
          lock_passwd: false
          passwd: ${var.ssh_password}
          ssh-authorized-keys:
            - ${data.local_file.ssh-pubkey.content}
        - name: wordpress
          sudo: false
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
        - path: /etc/ssh/sshd_config
          content: |
            PermitRootLogin no
            PasswordAuthentication yes
          append: true
    EOF
  }

  part {
    filename     = "runcmd"
    content_type = "text/cloud-config"
    content      = <<-EOF
      runcmd:
        - cp /etc/skel/.bashrc /home/drew/.profile
        - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/drew/.profile
        - chown drew:drew /home/drew/.profile
        - systemctl restart ssh
        # - while [ ! -f /tmp/postdeploy.zip ]; do echo "Waiting for postdeploy.zip to transfer..."; sleep 5; done
        # - unzip /tmp/postdeploy.zip -d /tmp
        # - /tmp/projects/wordpress/lemp-install.sh
      EOF
  }
}