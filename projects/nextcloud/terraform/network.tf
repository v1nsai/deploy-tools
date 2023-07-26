resource "openstack_networking_network_v2" "nextcloud_network" {
  name           = "nextcloud_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "nextcloud_subnet" {
  name       = "nextcloud_subnet"
  network_id = openstack_networking_network_v2.nextcloud_network.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}