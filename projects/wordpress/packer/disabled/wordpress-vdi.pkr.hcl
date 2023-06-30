source "qemu" "wordpress" {
  iso_url              = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum         = "b2f77380d6afaa6ec96e41d5f9571eda"
  format               = "qcow2"
  ssh_username         = "root"
  ssh_private_key_file = "~/.ssh/wordpress"
  vm_name              = "wordpress"
  disk_image           = true
  boot_wait            = "10s"
  use_default_display  = true
  headless             = false
  http_directory       = "projects/wordpress/packer/cloud-data"
  vnc_port_min         = 5900
  vnc_port_max         = 5900
  ssh_timeout          = "20m"
  qemuargs             = [["-smbios", "type=1,serial=ds=nocloud-net;instance-id=packer;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]]
}

source "virtualbox-iso" "wordpress" {
  guest_os_type = "Ubuntu_64"
  iso_url = "http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso"
  iso_checksum = "md5:769474248a3897f4865817446f9a4a53"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.virtualbox-iso.basic-example"]
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

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/install.sh"
    destination = "/tmp/provisioner-install.sh"
  }

  provisioner "file" {
    source      = "${path.cwd}/projects/wordpress/install.sh"
    destination = "/home/localadmin/provisioner-install2.sh"
  }

  provisioner "shell" {
    inline = [
      "mv /tmp/provisioner-install.sh /home/localadmin/provisioner-install.sh"
    ]
  }

  # provisioner "shell" {
  #   inline = ["echo '/tmp/install.sh' | sudo tee -a /etc/rc.local"]
  # }
}
