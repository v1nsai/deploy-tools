resource "openstack_networking_network_v2" "plex" {
  name           = "plex"
  external       = "false"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "plex_subnet" {
  name       = "plex_subnet"
  network_id = "${openstack_networking_network_v2.plex.id}"
  cidr       = "10.0.20.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "plex_router" {
  name                  = "plex_router"
  admin_state_up        = true
  external_network_id   = "0f00a093-4a7d-4026-b57c-e2cc04f3632c"
}

resource "openstack_networking_router_interface_v2" "plex_subnet_interface" {
  router_id = "${openstack_networking_router_v2.plex_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.plex_subnet.id}"
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.plex.id}"
  fixed_ip    = "${openstack_compute_instance_v2.plex.network.0.fixed_ip_v4}"
  depends_on  = [ openstack_networking_floatingip_v2.myip, openstack_compute_instance_v2.plex ]
}
