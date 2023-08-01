resource "openstack_compute_instance_v2" "nextcloud" {
  name            = "nextcloud"
  # image_name      = "nextcloud"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.c2.medium"
  key_pair        = "nextcloud"
  security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data       = local.cloud_config

  network {
    name = "nextcloud"
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.102" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.nextcloud.id
  fixed_ip    = openstack_compute_instance_v2.nextcloud.network.0.fixed_ip_v4
}
