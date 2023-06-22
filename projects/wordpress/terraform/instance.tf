resource "openstack_compute_instance_v2" "instance" {
  name            = "instance"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

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
  #   host        = "216.87.32.215"
  # }
  # depends_on = [ openstack_networking_network_v2.wordpress, openstack_networking_subnet_v2.wordpress_subnet ]
}

output "wordpress_ip" {
  value = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.215"
  instance_id = "${openstack_compute_instance_v2.wordpress.id}"
  fixed_ip    = "${openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4}"
}
