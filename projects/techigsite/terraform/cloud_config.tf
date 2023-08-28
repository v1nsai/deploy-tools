variable "domain" { type = string }
variable "ssl_provisioner" { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_compose  = file("${path.cwd}/projects/wordpress/docker/docker.sh")
  ssh_key         = file(pathexpand("~/.ssh/techig-site"))
  ssh_pubkey      = file(pathexpand("~/.ssh/techig-site.pub"))

  cloud_config    = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          SSL_PROVISIONER=${var.ssl_provisioner}
          # ADMIN_PASSWD=';lkj;lkj'
        append: true
      - path: /opt/wp-deploy/docker.sh
        permissions: '0755'
        content: |
          ${indent(6, local.docker_compose)}
        owner: localadmin:localadmin
  EOF
}
