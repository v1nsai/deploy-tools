variable "ssh_password" { type = string }
variable "domain" { type = string }
variable "ssl_provisioner" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = false
  base64_encode = false

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
        - path: /root/shutdown.sh
          permissions: '0755'
          content: |
            ${indent(6, local.shutdown_script)}
        - path: /opt/wp-deploy/docker-compose.yaml
          owner: localadmin:localadmin
          content: |
            ${indent(6, local.docker_compose)}
        - path: /opt/wp-deploy/nginx/conf/default.conf
          owner: localadmin:localadmin
          content: |
            ${indent(6, local.nginx_conf)}
      runcmd:
        - echo "0 19-3 * * * /root/shutdown.sh" | crontab -
        - echo
        # - echo 'tail -f /opt/wp-deploy/install.sh.log' | tee -a /home/localadmin/.profile
        # - chown localadmin:localadmin -R /home/localadmin
    EOF
  }
}

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_compose = file("${path.cwd}/projects/wordpress/docker/docker-compose.yaml")
  nginx_conf = file("${path.cwd}/projects/wordpress/docker/nginx/conf/default.conf")
}
