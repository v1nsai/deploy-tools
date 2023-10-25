variable "hashed_passwd"     { type = string }

locals {
  shutdown_script = file("${path.cwd}/scripts/shutdown.sh")
  ssh_pubkey      = file(pathexpand("~/.ssh/nextcloud-testing.pub"))

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
          URL=nextcloud-testing.techig.com
          STAGING=false
        append: true
  EOF
}
