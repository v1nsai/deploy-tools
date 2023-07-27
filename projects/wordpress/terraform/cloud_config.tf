variable "ssh_password" { type = string }
variable "domain" { type = string }
variable "ssl_provisioner" { type = string }
variable "hashed_passwd" { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_compose  = file("${path.cwd}/projects/wordpress/docker/docker.sh")
  ssh_key         = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey      = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config    = <<-EOF
    #cloud-config
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
      - path: /opt/wp-deploy/docker.sh
        permissions: '0755'
        content: |
          ${indent(6, local.docker_compose)}
        owner: localadmin:localadmin
  EOF
}
