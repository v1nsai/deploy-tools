resource "openstack_compute_instance_v2" "wireguard" {
  name            = "wireguard"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.c2.medium"
  key_pair        = "wireguard"
  security_groups = ["default", "ssh-ingress", "wireguard-security_group"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
  depends_on = [ openstack_networking_subnet_v2.wordpress_subnet ]
#   provisioner "file" {
#     source      = "config.cfg"
#     destination = "/opt/config.cfg"
#   }
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.wireguard.id}"
  fixed_ip    = "${openstack_compute_instance_v2.wireguard.network.0.fixed_ip_v4}"
}

resource "openstack_networking_network_v2" "wordpress" {
  name           = "wordpress"
  external       = "false"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "wordpress_subnet" {
  name       = "wordpress_subnet"
  network_id = "${openstack_networking_network_v2.wordpress.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "wordpress_router" {
  name                = "wordpress_router"
  admin_state_up      = true
  external_network_id = "b1d12129-bbfc-4482-a5d2-c20458459ddc"
}

resource "openstack_networking_router_interface_v2" "wordpress_subnet_interface" {
  router_id = "${openstack_networking_router_v2.wordpress_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.wordpress_subnet.id}"
}