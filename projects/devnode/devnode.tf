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

  # personality {
  #   file     = "/home/localadmin/.ssh/personality"
  #   content = data.local_sensitive_file.private-key.content
  # }

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

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = openstack_networking_floatingip_v2.myip.address
  instance_id = openstack_compute_instance_v2.devnode.id
  # fixed_ip    = openstack_compute_instance_v2.devnode.access_ip_v4
}
