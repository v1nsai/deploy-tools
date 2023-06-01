resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_id        = "012cb821-5b05-48a5-b33e-89040561fbc4" # Debian 11
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = data.cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
  # depends_on = [ openstack_networking_network_v2.wordpress, openstack_networking_subnet_v2.wordpress_subnet ]
}