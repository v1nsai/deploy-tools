variable "ssh_password" { type = string }
variable "domain" { type = string }
variable ssl_provisioner { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

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
      EOF
  }

  # part {
  #   filename     = "runcmd"
  #   content_type = "text/cloud-config"
  #   content      = <<-EOF
  #     runcmd:
  #       - mkdir -p /opt/wp-deploy
  #       - chown localadmin:localadmin -R /opt/wp-deploy
  #       - cp /etc/skel/.bashrc /home/localadmin/.bashrc
  #       - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
  #       - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
  #       - cp -f /home/localadmin/.ssh/config /home/wordpress/.ssh/config
  #       - chown localadmin:localadmin -R /home/localadmin/
  #       - sudo su - localadmin -c "bash /opt/wp-deploy/install.sh" > /opt/wp-deploy/install.log 2>&1
  #       - systemctl restart ssh
  #     EOF
  # }
}
