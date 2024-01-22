variable "hashed_passwd" { type = string }

locals {
  ssh_pubkey = file(pathexpand("~/.ssh/nextcloud-testing.pub"))

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
          URL=
          STAGING=true
        append: true
      # - path: /etc/fstab
      #   append: true
      #   content: |
      #     /dev/vdb /var/lib/docker ext4 defaults 0 0
      # - path: /etc/docker/daemon.json
      #   content: |
      #     {
      #       "data-root": "/mnt/nextcloud-backup/docker-data"
      #     }
    # runcmd:
      # - systemctl stop docker.*
      # - mkdir -p /mnt/docker-data
      # - chmod 755 /mnt/docker-data
      # - mv /var/lib/docker/* /mnt/docker-data
      # - mount /dev/vdb /mnt/docker-data
      # - chmod -R 755 /mnt/docker-data
      # - cat /etc/docker/daemon.json | tee -a /var/log/docker-daemon-test.log
      # - systemctl start docker
  EOF
}
