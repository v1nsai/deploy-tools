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
        - path: /etc/ssl.key
          content: |
            ${data.local_file.ssl_key.content}
          owner: root:www-data
          permissions: '0640'
        - path: /etc/ssl.crt
          content: |
            ${data.local_file.ssl_crt.content}
          owner: root:www-data
          permissions: '0640'
      EOF
  }
}
