source "qemu" "wordpress" {
  iso_url              = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum         = "b2f77380d6afaa6ec96e41d5f9571eda"
  format               = "qcow2"
  ssh_username         = "localadmin"
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

  provisioner "shell-local" {
    inline = [
      # "cat projects/wordpress/install.sh | base64 -w 0 > projects/wordpress/install.sh.base64", # Linux
      "cat projects/wordpress/install.sh | base64 > projects/wordpress/install.sh.base64", # MacOS
      "yq -i '.write_files[0].content = load_str(\"projects/wordpress/install.sh.base64\")' projects/wordpress/packer/cloud-data/user-data"
    ]
  }

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

  provisioner "shell" {
    inline = [
      "echo '/opt/wp-deploy/install.sh' | sudo tee -a /etc/rc.local",
      "sudo mkdir -p /opt/wp-deploy/ansible",
      "sudo chown localadmin:localadmin -R /opt/wp-deploy",
      "mv /tmp/wp-deploy/* /opt/wp-deploy/",
    ]
  }
}
