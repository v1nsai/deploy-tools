source "openstack" "monitoring" {
  username             = var.user_name
  password             = var.password
  tenant_name          = var.tenant_name
  identity_endpoint    = var.auth_url
  flavor               = "alt.st1.nano"
  image_name           = "monitoring"
  source_image         = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  ssh_username         = "localadmin"
  ssh_keypair_name     = "monitoring"
  ssh_private_key_file = "~/.ssh/monitoring"
  ssh_timeout          = "20m"
  reuse_ips            = true
  networks             = ["d545fad5-fc62-40c1-8cf4-26cd9f600d06"] # nextcloud network id
  floating_ip_network  = "External"
  security_groups      = ["default", "ssh-ingress"]
  user_data            = local.cloud_config
}

build {
  sources = ["source.openstack.wordpress"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/monitoring",
      "sudo chown localadmin:localadmin -R /etc/monitoring"
    ]
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/blackbox-exporter-dashboard.json"
    destination = "/etc/monitoring/blackbox-exporter-dashboard.json"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/blackbox.yml"
    destination = "/etc/monitoring/blackbox.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/docker-compose.yml"
    destination = "/etc/monitoring/docker-compose.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/grafana_dashboards.yml"
    destination = "/etc/monitoring/grafana_dashboards.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/grafana_datasources.yml"
    destination = "/etc/monitoring/grafana_datasources.yml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/node-exporter-dashboard.json"
    destination = "/etc/monitoring/node-exporter-dashboard.json"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/monitoring/docker/prometheus.yml"
    destination = "/etc/monitoring/prometheus.yml"
  }

  provisioner "shell" {
    inline = [
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /etc/monitoring",
      "echo '@reboot docker-compose -f /etc/monitoring/docker-compose.yml up -d > /var/log/monitoring-deploy.log 2>&1' | sudo crontab -",
      "cloud-init status --wait"
    ]
  }
}
