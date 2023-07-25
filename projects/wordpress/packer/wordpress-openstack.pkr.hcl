source "openstack" "wordpress" {
  username             = var.user_name
  password             = var.password
  tenant_name          = var.tenant_name
  identity_endpoint    = var.auth_url
  flavor               = "alt.st1.nano"
  image_name           = "wordpress"
  source_image         = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  ssh_username         = "localadmin"
  ssh_keypair_name     = "wordpress"
  ssh_private_key_file = "~/.ssh/wordpress"
  ssh_timeout          = "20m"
  reuse_ips            = true
  networks             = ["215f7325-1b59-4088-8026-10568369732d"]
  floating_ip_network  = "External"
  security_groups      = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data            = local.cloud_config
  # use_blockstorage_volume = true
  # volume_size             = 10
}

build {
  sources = ["source.openstack.wordpress"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/wp-deploy/ansible",
      "mkdir -p /tmp/wp-deploy/ansible",
      "sudo chown localadmin:localadmin -R /opt/wp-deploy"
    ]
  }

  provisioner "file" {
    source      = "${path.cwd}/auth/cloudflare.env"
    destination = "/tmp/wp-deploy/cloudflare.env"
  }

  provisioner "file" {
    source      = "${path.cwd}/scripts/cloudflare/create-temp-record.sh"
    destination = "/tmp/wp-deploy/create-temp-record.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/scripts/cloudflare/list-records.sh"
    destination = "/tmp/wp-deploy/list-records.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/docker/docker.sh"
    destination = "/tmp/wp-deploy/docker.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/docker/docker-compose.yaml"
    destination = "/tmp/wp-deploy/docker-compose.yaml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/docker/generate_certs.sh"
    destination = "/tmp/wp-deploy/generate_certs.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/docker/Dockerfile"
    destination = "/tmp/wp-deploy/Dockerfile"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/docker/nginx/templates/default.conf.template"
    destination = "/tmp/wp-deploy/nginx/templates/default.conf.template"
  }

  provisioner "shell" {
    inline = [
      "mv /tmp/wp-deploy/* /opt/wp-deploy/",
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "echo 'cd /opt/wp-deploy' >> /home/localadmin/.profile",
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown wordpress:wordpress -R /home/wordpress",
      "echo '@reboot /opt/wp-deploy/docker.sh > /opt/wp-deploy/docker.sh.log 2>&1' | sudo crontab -",
      "cloud-init status --wait"
    ]
  }
}
