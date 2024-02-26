# variable "url"  { type = string }

locals {
  cloud_config    = <<-EOF
    #cloud-config
    packages:
      - nnn
      - net-tools
    write_files:
      - path: /etc/environment
        content: |
          CERTRESOLVER=
        append: true
  EOF
}