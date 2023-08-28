variable "domain" { type = string }

locals {
  docker_compose  = file("${path.cwd}/projects/wordpress/docker/docker.sh")
  ssh_key         = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey      = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config    = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          STAGING=true
          # SUBDOMAIN=
          # ONLY_SUBDOMAINS=
        append: true
  EOF
}
