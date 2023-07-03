variable "ssh_password" { type = string }
variable "domain" { type = string }
variable ssl_provisioner { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  # part {
  #   filename     = "packages"
  #   content_type = "text/cloud-config"
  #   content      = <<-EOF
  #     package_update: true
  #     packages:
  #       - python3
  #       - python3-pip
  #       - python3-venv
  #     EOF
  # }

  # part {
  #   filename     = "users"
  #   content_type = "text/cloud-config"
  #   content      = <<-EOF
  #     users:
  #       - name: localadmin
  #         sudo: ['ALL=(ALL) NOPASSWD:ALL']
  #         groups: [sudo, www-data]
  #         shell: /bin/bash
  #         lock_passwd: false
  #         passwd: ${var.ssh_password}
  #         ssh_authorized_keys:
  #           - ${data.local_file.ssh-pubkey.content}
  #       - name: wordpress
  #         groups: [www-data]
  #         shell: /bin/bash
  #         lock_passwd: false
  #     EOF
  # }

  part {
    filename     = "write_files"
    content_type = "text/cloud-config"
    content      = <<-EOF
      write_files:
        - path: /etc/environment
          content: |
            DOMAIN=${var.domain}
            SSL_PROVISIONER=${var.ssl_provisioner}
          append: true
        # - path: /etc/crontab
        #   content: |
        #     30 23   * * *   root    /usr/sbin/shutdown -h 

        #   append: true
        #   defer: true
      EOF
  }

  part {
    filename     = "runcmd"
    content_type = "text/cloud-config"
    content      = <<-EOF
      runcmd:
        - mkdir -p /opt/wp-deploy
        - chown localadmin:localadmin -R /opt/wp-deploy
        - cp /etc/skel/.bashrc /home/localadmin/.bashrc
        - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
        - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
        - cp -f /home/localadmin/.ssh/config /home/wordpress/.ssh/config
        - chown localadmin:localadmin -R /home/localadmin/
        - sudo su - localadmin -c "bash /opt/wp-deploy/install.sh" > /opt/wp-deploy/install.log 2>&1
        - systemctl restart ssh
      EOF
  }
}

  #       - path: /opt/wp-deploy/install.sh
  #         content: |
  #           ${data.local_file.install_sh.content}
  #         owner: localadmin:localadmin
  #         permissions: '0777'
  #         encoding: base64
  #         defer: true
  #       - path: /home/localadmin/.ssh/id_rsa
  #         content: |
  #           ${data.local_file.github_anonymous.content}
  #         owner: localadmin:localadmin
  #         permissions: '0600'
  #         encoding: base64
  #         defer: true
  #       - path: /home/localadmin/.ssh/id_rsa.pub
  #         content: |
  #           ${data.local_file.github_anonymous_pub.content}
  #         owner: localadmin:localadmin
  #         permissions: '0644'
  #         defer: true
  #       - path: /opt/wp-deploy/ansible/inventory.yml
  #         content: |
  #           ${data.local_file.ansible-inventory.content}
  #         owner: localadmin:localadmin
  #         permissions: '0644'
  #         defer: true
  #         encoding: base64
  #       - path: /opt/wp-deploy/ansible/deploy.yml
  #         content: |
  #           ${data.local_file.ansible-playbook.content}
  #         owner: localadmin:localadmin
  #         permissions: '0644'
  #         defer: true
  #         encoding: base64