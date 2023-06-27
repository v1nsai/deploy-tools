# variable "mysql_root_password" { type = string }
# variable "mysql_wp_user_password" { type = string }
# variable "plex_username" { type = string }
# variable "plex_password" { type = string }
# variable "lemp_install_script" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  # part {
  #   filename     = "packages"
  #   content_type = "text/cloud-config"
  #   content      = <<-EOF
  #     package_update: true
  #     packages:
  #       - easy-rsa
  #       - openssl
  #       - net-tools
  #       - unzip
  #       - nginx
  #       - mariadb-server
  #       - php-fpm
  #       - php-mysql
  #       - php-curl
  #       - php-gd
  #       - php-intl
  #       - php-mbstring
  #       - php-soap
  #       - php-xml
  #       - php-xmlrpc
  #       - php-zip
  #     EOF
  # }

  part {
    filename     = "users"
    content_type = "text/cloud-config"
    content      = <<-EOF
      users:
        - name: plex
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: [sudo, www-data]
          shell: /bin/bash
          lock_passwd: false
          passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
          ssh-authorized-keys:
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPNG6afWDqOCptAg2ERApA42HX7VG7Nw1hLjuCYpb8Ij36A0F/OUxDpA1O/+EKibLL+MgpwMzC3J5a+8ifkRH3Cr/OwOeiq/lcHgiC3rJcLr8kyNLwQmpYhSZkQMR0m2Y850Okix5dmNlK8KcE5RwG3q04DY0W09Rx/LWlUm1Z0ipkJ4NECDWTRKEoelJ72YREB1j9awJFBKLn2Ip8lylK7lrZu1Q64mOib551HYOr2xCLdTUoUI9pReesBVYKdVinsyyjuZ5HAxb8SOEdGA+8AGLhfoBdcQ7zNHfGmOrCtTsZqL1y/HQM4EimhBBUdT7tnJzWitTlx4bA7qo+cZ5bX5Zy+VR1rFpUit2xzU+1jImExnK3ltDAPec6qMDrK9wOFwJna5WKTKtEEStRNiv0yNDElrvSMu2srriORH9HwINOnSOuWDiYldlTJnLW8P4h0EBf8hw2ZKy4YOopDEuStthli6QlVKYji1qNMh2kKiuxAmWv6nzG9KrZJl/nohehtaXYYsXNk5jl3AOYnrC6xgLDcyHd1II78G+lujvUl0EJPmnYQA7rJVqem2I516ixTBaVR5htXvPclLXl+kmmOwtltNCRqPXaWB/9e3LFyZuO7A/r4UEC16v9t0OnEHvjRJ6dLQey+hnJN398egXAQmXjSXVJgNejsxCz7uUzSw== doctor_ew@Tiffanys-Air
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
        - cp /etc/skel/.bashrc /home/plex/.profile
        - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/plex/.profile
        - chown plex:plex /home/plex/.profile
      EOF
  }
}