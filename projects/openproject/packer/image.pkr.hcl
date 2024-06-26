source "openstack" "openproject" {
  username             = var.user_name
  password             = var.password
  tenant_name          = var.tenant_name
  identity_endpoint    = var.auth_url
  flavor               = "alt.st1.nano"
  image_name           = "openproject"   # openproject-latest-Ubuntu_22.04
  source_image         = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  ssh_username         = "localadmin"
  ssh_keypair_name     = "openproject"
  ssh_private_key_file = "~/.ssh/openproject"
  ssh_timeout          = "20m"
  reuse_ips            = true
  networks             = ["59f20288-7906-41f6-8e13-0839b7d43ee6"] # openproject network id
  floating_ip_network  = "External"
  security_groups      = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data            = local.cloud_config
}

build {
  sources = ["source.openstack.openproject"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/deploy/",
      "sudo chown localadmin:localadmin -R /opt/deploy",
    ]
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/openproject/install.sh"
    destination = "/opt/deploy/install.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/openproject/docker-compose.yaml"
    destination = "/opt/deploy/docker-compose.yaml"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/openproject/swag-docker-compose.yaml"
    destination = "/opt/deploy/swag-docker-compose.yaml"
  }

  provisioner "shell" {
    inline = [
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config",
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown localadmin:localadmin -R /opt/deploy",
      "echo '@reboot /opt/deploy/install.sh > /var/log/deploy.log 2>&1' | sudo crontab -",
      "cloud-init status --wait"
    ]
  }
}
