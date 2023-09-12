resource "openstack_networking_network_v2" "dashboards" {
  name           = "dashboards"
  external       = "false"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "dashboards_subnet" {
  name       = "dashboards_subnet"
  network_id = "${openstack_networking_network_v2.dashboards.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "dashboards_router" {
  name                = "dashboards_router"
  admin_state_up      = true
  external_network_id = "b1d12129-bbfc-4482-a5d2-c20458459ddc"
}

resource "openstack_networking_router_interface_v2" "dashboards_subnet_interface" {
  router_id = "${openstack_networking_router_v2.dashboards_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.dashboards_subnet.id}"
}
