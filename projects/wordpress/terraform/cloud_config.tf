variable "ssh_password" { type = string }
variable "domain" { type = string }
variable "ssl_provisioner" { type = string }
variable "hashed_passwd" { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  docker_compose  = file("${path.cwd}/projects/wordpress/docker/docker-compose.yaml")
  ssh_key         = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey      = file(pathexpand("~/.ssh/wordpress.pub"))

  cloud_config    = <<-EOF
    #cloud-config
    ssh_pwauth: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo, docker
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${local.ssh_pubkey}
      - name: wordpress
        groups: [www-data]
        shell: /bin/bash
        lock_passwd: false
        ssh_pwauth: true
        passwd: ${var.hashed_passwd}
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
    runcmd:
      - echo "0 19-3 * * * /root/shutdown.sh" | crontab -
      - chown localadmin:localadmin -R /home/localadmin
      - chown localadmin:localadmin -R /opt/wp-deploy
  EOF
}
