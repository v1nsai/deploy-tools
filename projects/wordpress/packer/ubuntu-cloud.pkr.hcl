# packer {
#   required_plugins {
#     docker = {
#       version = ">= 0.0.7"
#       source = "github.com/hashicorp/docker"
#     }
#   }
# }

# source "docker" "ubuntu" {
#   image  = "ubuntu:xenial"
#   commit = true
# }

# build {
#   name    = "packer-ubuntu"
#   sources = [
#     "source.docker.ubuntu"
#   ]
# }

source "qemu" "ubuntu-cloud" {
  iso_url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum     = "b2f77380d6afaa6ec96e41d5f9571eda"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  #   disk_size        = "1G"
  format = "qcow2"
  #   accelerator       = "kvm"
  #   http_directory    = "path/to/httpdir"
  ssh_username = "localadmin"
  ssh_password = "Ch4ngeMe!"
  ssh_timeout  = "20m"
  vm_name      = "ubuntu-packer"
  #   net_device        = "virtio-net"
  #   disk_interface    = "virtio"
  disk_image = true
  boot_wait  = "10s"
  #   boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6-ks.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.ubuntu-cloud"]
}
