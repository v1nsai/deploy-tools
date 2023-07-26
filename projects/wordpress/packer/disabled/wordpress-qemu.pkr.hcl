source "qemu" "wordpress" {
  iso_url              = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum         = "b2f77380d6afaa6ec96e41d5f9571eda"
  format               = "qcow2"
  ssh_username         = "root"
  ssh_private_key_file = "~/.ssh/wordpress"
  vm_name              = "wordpress"
  disk_image           = true
  disk_size            = 10000
  boot_wait            = "10s"
  use_default_display  = true
  headless             = false
  http_directory       = "projects/wordpress/packer/cloud-data"
  vnc_port_min         = 5900
  vnc_port_max         = 5900
  ssh_timeout          = "20m"
  qemuargs             = [["-smbios", "type=1,serial=ds=nocloud-net;instance-id=packer;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]]
}

build {
  sources = ["source.qemu.wordpress"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/wp-deploy",
      "sudo chown localadmin:localadmin -R /opt/wp-deploy",
      "mkdir -p /tmp/wp-deploy/ansible"
    ]
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

  provisioner "file" {
    source      = "${path.cwd}/auth/cloudflare.env"
    destination = "/tmp/wp-deploy/cloudflare.env"
  }

  provisioner "file" {
    source      = "${path.cwd}/scripts/cloudflare/create-temp-record.sh"
    destination = "/tmp/wp-deploy/create-temp-record.sh"
  }

  provisioner "shell" {
    inline = [
      "mv /tmp/wp-deploy/* /opt/wp-deploy/",
      "cp -f /etc/skel/.bashrc /home/localadmin/.profile",
      "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/localadmin/.profile",
      "echo 'tail -f /opt/wp-deploy/install.sh.log' | tee -a /home/localadmin/.bashrc"
      "sudo chown localadmin:localadmin -R /home/localadmin && sudo chown wordpress:wordpress -R /home/wordpress",
      "echo '@reboot /opt/wp-deploy/install.sh > /opt/wp-deploy/install.sh.log 2>&1' | crontab -"
    ]
  }
}
