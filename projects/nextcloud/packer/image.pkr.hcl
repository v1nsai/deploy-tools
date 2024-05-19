source "openstack" "nextcloud" {
  username             = var.user_name
  password             = var.password
  tenant_name          = var.tenant_name
  identity_endpoint    = var.auth_url
  flavor               = "alt.st1.nano"
  image_name           = "nextcloud-dev"
  source_image         = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  ssh_username         = "localadmin"
  ssh_keypair_name     = "nextcloud"
  ssh_private_key_file = "~/.ssh/nextcloud"
  ssh_timeout          = "20m"
  reuse_ips            = true
  networks             = ["d545fad5-fc62-40c1-8cf4-26cd9f600d06"]
  floating_ip_network  = "External"
  security_groups      = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data            = local.cloud_config
  # use_blockstorage_volume = true
  # volume_size             = 10
}

build {
  sources = ["source.openstack.nextcloud"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/deploy/",
      "sudo chown localadmin:localadmin -R /opt/deploy",
      "sudo mkdir -p /etc/traefik/",
      "sudo chown localadmin:localadmin -R /etc/traefik/",
    ]
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/nextcloud/docker/docker-compose.yaml"
    destination = "/opt/deploy/docker-compose.yaml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/nextcloud/docker/routes.yaml"
    destination = "/etc/traefik/routes.yaml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/nextcloud/docker/traefik.yaml"
    destination = "/etc/traefik/traefik.yaml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/nextcloud/docker/install.sh"
    destination = "/opt/deploy/install.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/traefik/proxy.sh"
    destination = "/opt/deploy/proxy.sh"
  }

  provisioner "shell" {
    inline = [
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "echo '@reboot /opt/deploy/install.sh > /var/log/deploy.log 2>&1' | sudo crontab -",
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /opt/deploy",
      "echo 'waiting for cloud-init to finish...'",
      "cloud-init status --wait"
    ]
  }
}
