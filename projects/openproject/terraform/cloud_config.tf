variable "hashed_passwd"     { type = string }
variable "openproject_email" { type = string }
variable "openproject_host"  { type = string }
variable "backuphost"        { type = string } 
variable "backupdirs"        { type = string }
variable "backuprepo"        { type = string }
variable "backupkey"         { type = string }
variable "backupuser"        { type = string }

locals {
  cloud_config = <<-EOF
    #cloud-config
    packages:
      - nnn
      - net-tools
      - docker
      - docker-compose
      - borgbackup
    package_update: true
    ssh_pwauth: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo, docker
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${file(pathexpand("~/.ssh/openproject.pub"))}
    write_files:
      - path: /etc/environment
        content: |
          OPENPROJECT_ADMIN__EMAIL="${var.openproject_email}"
          OPENPROJECT_HOST__NAME="${var.openproject_host}"
          OPDATA=/var/lib/openproject/opdata
          PGDATA=/var/lib/openproject/pgdata
          URL="${var.openproject_host}"
          BACKUPHOST="${var.backuphost}"
          BACKUPDIRS="${var.backupdirs}"
          BACKUPREPO="${var.backuprepo}"
          BACKUPKEY="${var.backupkey}"
          BACKUPUSER="${var.backupuser}"
        append: true
      - path: /opt/deploy/install.sh
        permissions: '0755'
        content: |
          ${indent(10, file("${path.cwd}/projects/openproject/install.sh"))}
      - path: /opt/deploy/docker-compose.yaml
        permissions: '0644'
        content: |
          ${indent(10, file("${path.cwd}/projects/openproject/docker-compose.yaml"))}
      - path: /etc/traefik/traefik.yaml
        permissions: '0644'
        content: |
          ${indent(10, file("${path.cwd}/projects/traefik/traefik.yaml"))}
      - path: /etc/traefik/routes.yaml
        permissions: '0644'
        content: |
          ${indent(10, file("${path.cwd}/projects/openproject/routes.yaml"))}
      - path: /home/localadmin/.ssh/id_rsa
        permissions: '0600'
        content: |
          ${file(pathexpand("~/.ssh/backups-openproject"))}
      - path: /etc/cron.d/weekly-backup
        permissions: '0644'
        content: |
          0 0 * * 0 root /opt/deploy/backup.sh
      - path: /opt/deploy/backup.sh
        permissions: '0755'
        content: |
          ${indent(10, file("${path.cwd}/projects/openproject/backup.sh"))}
    runcmd:
      - cp -f /etc/skel/.bashrc /home/localadmin/.bashrc
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
      - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
      - /opt/deploy/install.sh > /var/log/install.log 2>&1
      - chown localadmin:localadmin -R /home/localadmin/
      - chown localadmin:localadmin -R /opt/deploy/
  EOF
}

# output "cloud_config" {
#   value = local.cloud_config
# }
