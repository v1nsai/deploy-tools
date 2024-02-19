resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_name      = "wordpress-dev" # wordpress-latest-Ubuntu_22.04
  flavor_name     = "alt.st1.small"
  key_pair        = "wordpress"
  user_data       = local.cloud_config
  security_groups = [ "default", "ssh-ingress", "http-ingress", "https-ingress" ]

  network {
    name = "wordpress"
    # port = openstack_networking_port_v2.port.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "216.87.32.85"
  instance_id = openstack_compute_instance_v2.wordpress.id
}

# resource "openstack_networking_port_v2" "port" {
#   name       = "wordpress"
#   network_id = data.openstack_networking_network_v2.wordpress.id
#   security_group_ids = [
#     data.openstack_networking_secgroup_v2.default.id,
#     data.openstack_networking_secgroup_v2.ssh-ingress.id,
#     data.openstack_networking_secgroup_v2.http-ingress.id,
#     data.openstack_networking_secgroup_v2.https-ingress.id
#   ]
# }

# resource "openstack_networking_floatingip_associate_v2" "fipa_1" {
#   floating_ip = openstack_networking_floatingip_v2.fip.address
#   port_id     = openstack_networking_port_v2.port.id
# }

# resource "openstack_networking_floatingip_v2" "fip" {
#   pool    = "External"
#   address = "216.87.32.85"
# }