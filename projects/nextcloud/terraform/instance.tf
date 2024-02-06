resource "openstack_compute_instance_v2" "nextcloud" {
  name            = "nextcloud"
  # image_name      = "nextcloud"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st1.small"
  key_pair        = "nextcloud"
  security_groups = [ "default", "SSH ingress", "HTTP ingress", "HTTPS ingress", "nextcloud-talk" ]
  user_data       = local.cloud_config

  network {
    name = "techigsite"
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = openstack_compute_floatingip_v2.floating_ip.address 
  instance_id = openstack_compute_instance_v2.nextcloud.id
  fixed_ip    = openstack_compute_instance_v2.nextcloud.network.0.fixed_ip_v4
}

resource "openstack_compute_floatingip_v2" "floating_ip" {
  pool = "External"
}