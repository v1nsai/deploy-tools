variable "ssh_password"     { type = string }
variable "domain"           { type = string }
variable "ssl_provisioner"  { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_sh       = file("${path.cwd}/projects/nextcloud/docker/docker.sh")
  ssh_pubkey      = file(pathexpand("~/.ssh/nextcloud.pub"))

  cloud_config = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          SUBDOMAIN=${var.ssl_provisioner}
        append: true
      - path: /root/shutdown.sh
        permissions: '0755'
        content: |
          ${indent(6, local.shutdown_script)}
  EOF
}
