resource "openstack_compute_instance_v2" "techig-site" {
  name            = "techig-site"
  image_name      = "WordPress"
  # image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.st1.small"
  key_pair        = "techig-site"
  security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data       = local.cloud_config

  network {
    name = "techig-site"
  }
  depends_on = [openstack_networking_network_v2.techig-site]
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.158" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.techig-site.id
  fixed_ip    = openstack_compute_instance_v2.techig-site.network.0.fixed_ip_v4
}

resource "openstack_networking_network_v2" "techig-site" {
  name           = "techig-site"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "techig-subnet" {
  name       = "techig-subnet"
  network_id = openstack_networking_network_v2.techig-site.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "techig-router" {
  name       = "techig-router"
  admin_state_up = "true"
  external_network_id = "b1d12129-bbfc-4482-a5d2-c20458459ddc"
}

resource "openstack_networking_router_interface_v2" "techig-router-interface" {
  router_id = openstack_networking_router_v2.techig-router.id
  subnet_id = openstack_networking_subnet_v2.techig-subnet.id
}