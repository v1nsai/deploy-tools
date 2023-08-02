resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_name      = "WordPress"
  # image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.st1.small"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data       = local.cloud_config

  network {
    name = "wordpress"
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.102" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.wordpress.id
  fixed_ip    = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}
