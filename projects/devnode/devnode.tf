resource "openstack_compute_instance_v2" "devnode" {
  name            = "devnode"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.c2.large"
  key_pair        = "devnode"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = local.cloud-init

  network {
    name = "wordpress"
  }

  # provisioner "file" {
  #     source = "${path.module}/install.sh"
  #     destination = "/home/localadmin/install.sh"
  # }

  # connection {
  #   type        = "ssh"
  #   user        = "localadmin"
  #   private_key = file(pathexpand("~/.ssh/wordpress"))
  #   host        = "${openstack_compute_floatingip_associate_v2.myip.address}"
  # }
  # depends_on = [ openstack_compute_floatingip_associate_v2.myip ]
}

locals {
  cloud-init = <<EOF
#cloud-config
ssh_pwauth: true
users:
  - name: localadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
    ssh_authorized_keys:
      - ${data.local_file.ssh-pubkey.content}
    ssh_keys:
      rsa_private: |
        ${indent(8, data.local_file.private-key.content)}
      rsa_public: |
        ${indent(8, data.local_file.ssh-pubkey.content)}
  EOF
}

output "cloud-init" {
  value = local.cloud-init
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = openstack_networking_floatingip_v2.myip.address
  instance_id = openstack_compute_instance_v2.devnode.id
  fixed_ip    = openstack_compute_instance_v2.devnode.access_ip_v4
}
