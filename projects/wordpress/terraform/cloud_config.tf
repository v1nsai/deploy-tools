variable "domain"  { type = string }
variable "staging" { type = bool }

locals {
  ssh_key         = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey      = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config    = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          # STAGING=${var.staging}
          # SUBDOMAIN=
          # ONLY_SUBDOMAINS=
        append: true
  EOF
}
