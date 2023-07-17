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
  # volume_size             = 50
}

build {
  # sources = ["source.qemu.wordpress"]
  sources = ["source.openstack.wordpress"]

  provisioner "shell-local" {
    inline = [
      # "cat projects/wordpress/install.sh | base64 -w 0 > projects/wordpress/install.sh.base64", # Linux
      "cat projects/wordpress/install.sh | base64 > projects/wordpress/install.sh.base64", # MacOS
      "yq -i '.write_files[0].content = load_str(\"projects/wordpress/install.sh.base64\")' projects/wordpress/packer/cloud-data/user-data"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/wp-deploy/ansible",
      "mkdir -p /tmp/wp-deploy/ansible",
      "sudo chown localadmin:localadmin -R /opt/wp-deploy"
    ]
  }

  provisioner "file" {
    source      = "projects/wordpress/ssh-config"
    destination = "/home/localadmin/.ssh/config"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/install.sh"
    destination = "/tmp/wp-deploy/install.sh"
  }

  provisioner "file" {
    source      = pathexpand("~/.ssh/github_anonymous")
    destination = "/home/localadmin/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = pathexpand("~/.ssh/github_anonymous.pub")
    destination = "/home/localadmin/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${path.root}/../ansible/inventory.yml"
    destination = "/tmp/wp-deploy/ansible/inventory.yml"
  }

  provisioner "file" {
    source      = "${path.root}/../ansible/deploy.yml"
    destination = "/tmp/wp-deploy/ansible/deploy.yml"
  }

  provisioner "shell" {
    inline = [
      "mv /tmp/wp-deploy/* /opt/wp-deploy/",
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown wordpress:wordpress -R /home/wordpress",
      "echo '@reboot /opt/wp-deploy/install.sh > /opt/wp-deploy/install.sh.log 2>&1' | crontab -",
      "sudo apt update && sudo apt install -y python3 python3-pip python3-venv net-tools"
    ]
  }
}
