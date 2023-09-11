resource "openstack_compute_instance_v2" "wireguard" {
  name            = "wireguard"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st1.small"
  key_pair        = "wireguard"
  security_groups = ["default", "ssh-ingress", "wireguard-security_group"]
  user_data       = local.cloud_config

  network {
    name = "wireguard"
  }

  depends_on = [ openstack_networking_network_v2.wireguard ]
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.38" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.wireguard.id
  fixed_ip    = openstack_compute_instance_v2.wireguard.network.0.fixed_ip_v4
}