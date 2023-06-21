source "qemu" "ubuntu-cloud" {
  iso_url              = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum         = "b2f77380d6afaa6ec96e41d5f9571eda"
  format               = "qcow2"
  ssh_username         = "localadmin"
  ssh_private_key_file = "~/.ssh/wordpress"
  vm_name              = "ubuntu-packer"
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

build {
  sources = ["source.qemu.ubuntu-cloud"]

  provisioner "file" {
    source      = "projects/wordpress/install.sh"
    destination = "/home/localadmin/install.sh"
  }

  provisioner "shell" {
    inline = [
      "echo '/home/localadmin/install.sh' | sudo tee -a /etc/rc.local"
    ]
  }
}
