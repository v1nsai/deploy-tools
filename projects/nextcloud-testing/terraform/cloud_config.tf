variable "hashed_passwd"     { type = string }

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
      - path: /opt/deploy/docker-compose.yaml
        content: |
          ${file("${path.cwd}/projects/nextcloud-testing/docker/docker-compose.yaml")}
        permissions: '0644'
        owner: localadmin:localadmin
      - path: /config/nginx/site-confs/default.conf
        content: |
          ${file("${path.cwd}/projects/nextcloud-testing/docker/nginx/site-confs/default.conf")}
        permissions: '0644'
        owner: localadmin:localadmin
      - path: /config/nginx/conf-templates/nextcloud.conf.template
        content: |
          ${file("${path.cwd}/projects/nextcloud-testing/docker/nginx/conf-templates/nextcloud.conf.template")}
        permissions: '0644'
        owner: localadmin:localadmin
      - path: /opt/deploy/install.sh
        content: |
          ${file("${path.cwd}/projects/nextcloud-testing/install.sh")}
        permissions: '0755'
        owner: localadmin:localadmin
      - path: /etc/cron.d/deploy
        content: |
          @reboot localadmin /opt/deploy/install.sh > /var/log/deploy.log 2>&1
        permissions: '0644'
        owner: root:root
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.profile
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile
      - sudo chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /opt/deploy
    EOF
}

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
#   EOF
# }
