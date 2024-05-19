variable "hashed_passwd" { type = string }

locals {
  blackbox_dashboard      = "${path.cwd}/projects/monitoring/docker/blackbox-exporter-dashboard.json"
  blackbox_config         = "${path.cwd}/projects/monitoring/docker/blackbox.yml"
  docker_compose          = "${path.cwd}/projects/monitoring/docker/docker-compose.yml"
  grafana_dashboards      = "${path.cwd}/projects/monitoring/docker/grafana_dashboards.yml"
  grafana_datasources     = "${path.cwd}/projects/monitoring/docker/grafana_datasources.yml"
  node_exporter_dashboard = "${path.cwd}/projects/monitoring/docker/node-exporter-dashboard.json"
  prometheus_config       = "${path.cwd}/projects/monitoring/docker/prometheus.yml"
  ssh_pubkey              = "${path.cwd}/auth/monitoring.pub"
  cloud-init = <<EOF
    #cloud-config
    package_update: true
    packages:
      - docker
      - docker-compose
    ssh_pwauth: true
    users:
      - name: localadmin
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin, sudo
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.hashed_passwd}
        ssh_authorized_keys:
          - ${file(local.ssh_pubkey)}
    write_files:
      - path: /etc/ssh/sshd_config
        content: |
          PermitRootLogin no
      - path: /etc/monitoring/blackbox_config.yml
        content: |
          ${file(local.blackbox_config)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/docker-compose.yml
        content: |
          ${file(local.docker_compose)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/grafana_dashboards.yml
        content: |
          ${file(local.grafana_dashboards)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/grafana_datasources.yml
        content: |
          ${file(local.grafana_datasources)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/prometheus_config.yml
        content: |
          ${file(local.prometheus_config)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/blackbox-exporter-dashboard.json
        content: |
          ${file(local.blackbox_dashboard)}
        owner: localadmin:localadmin
        permissions: '0644'
      - path: /etc/monitoring/node-exporter-dashboard.json
        content: |
          ${file(local.node_exporter_dashboard)}
        owner: localadmin:localadmin
        permissions: '0644'
    runcmd:
      - cp /etc/skel/.bashrc /home/localadmin/.bashrc
      - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.bashrc
      - cp -f /home/localadmin/.bashrc /home/localadmin/.profile
      - docker-compose -f /etc/monitoring/docker-compose.yml up -d > /var/log/monitoring-deploy.log 2>&1
      - chown localadmin:localadmin -R /home/localadmin/
  EOF
}
