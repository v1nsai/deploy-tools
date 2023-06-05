variable "mysql_root_password" { type = string }
variable "mysql_wp_user_password" { type = string }
variable "wordpress_username" { type = string }
variable "wordpress_password" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "packages"
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      packages:
        - easy-rsa
        - openssl
        - net-tools
        - unzip
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
          passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
          ssh-authorized-keys:
            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCX3ZnnojSpqi1R7CWmP7uVFU2fEd2uS4PYQpWC23ScmDGP7KFHeTJfMc6eMaAhbxfIXx2CFdsIhP5U58BFLmAxkUIM8lGnHgh1uME/aOMZokZrDhYnw0eaamVOg0rdKD/uaTo87ASoxpf0XYnrqcrYhFIQodxjsCC8pCU5Egjh9QDgHsniJ5vWEkxZGPQ4SXIj4txh8uXMI0mh57BWJRK0zJIDzZCxubtrOpWoQnVvg/ZV+Thgy0P9m7e8OHbaM3U/7p4DBd1MZ95jNwjefMeD5hR46T35rkR9w/ebEIKhGjz0UB2yRUZPOPqBzVfixYA6gfd5c1AhjluCyCqhLEMd Generated-by-Nova
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
        - path: /etc/environment
          permissions: "0644"
          owner: root
          append: true
          content: |
            MYSQL_ROOT_PASSWORD=${var.mysql_root_password}
            MYSQL_WP_USER_PASSWORD=${var.mysql_wp_user_password}
            WORDPRESS_USERNAME=${var.wordpress_username}
            WORDPRESS_PASSWORD=${var.wordpress_password}
        - path: /etc/ssh/sshd_config
          content: |
            Port 1355
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
        - while [ ! -f /tmp/postdeploy.zip ]; do echo "Waiting for postdeploy.zip to transfer..."; sleep 5; done
        - unzip /tmp/postdeploy.zip -d /tmp
        - /tmp/projects/wordpress/lemp-install.sh
      EOF
  }
}