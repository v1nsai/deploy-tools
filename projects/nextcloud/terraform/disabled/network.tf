resource "openstack_networking_network_v2" "nextcloud_network" {
  name           = "nextcloud"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "nextcloud_subnet" {
  name       = "nextcloud_subnet"
  network_id = openstack_networking_network_v2.nextcloud_network.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
  depends_on = [ openstack_networking_network_v2.nextcloud_network ]
}

resource "openstack_networking_router_v2" "nextcloud_router" {
  name       = "nextcloud_router"
  admin_state_up = "true"
  external_network_id = data.openstack_networking_network_v2.external_network.id
  depends_on = [ openstack_networking_subnet_v2.nextcloud_subnet ]
}

resource "openstack_networking_router_interface_v2" "nextcloud_router_interface" {
  router_id = openstack_networking_router_v2.nextcloud_router.id
  subnet_id = openstack_networking_subnet_v2.nextcloud_subnet.id
  depends_on = [ openstack_networking_router_v2.nextcloud_router ]
}

data "openstack_networking_network_v2" "external_network" {
  name = "External"
}
