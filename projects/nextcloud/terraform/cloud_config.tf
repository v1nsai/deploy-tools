variable "hashed_passwd"     { type = string }
variable "domain"           { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  ssh_pubkey      = file(pathexpand("~/.ssh/nextcloud.pub"))

  cloud_config = <<-EOF
    #cloud-config
    packages:
      - docker
      - docker-compose
      - net-tools
      - nnn
    package_update: true
    write_files:
      - path: /etc/environment
        content: |
          DOMAIN=${var.domain}
          SUBDOMAIN=nextcloud
          ONLY_SUBDOMAINS=true
          STAGING=false
        append: true
    runcmd:
      - echo 'cd /opt/nc-deploy' | tee -a /home/localadmin/.profile
      - echo 'tail -f /opt/nc-deploy/docker.log' | tee -a /home/localadmin/.profile
      - chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /opt/nc-deploy
  EOF
}

      # - ssh-keyscan github.com | tee -a /home/localadmin/.ssh/known_hosts
