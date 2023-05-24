resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress-bitnami"
  image_name      = "bitnami-wordpress-6.2.1-r0-debian-11-amd64"
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
  # depends_on = [ openstack_networking_network_v2.wordpress, openstack_networking_subnet_v2.wordpress_subnet ]
  #   provisioner "file" {
  #     source      = "config.cfg"
  #     destination = "/opt/config.cfg"
  #   }
}

## Floating IP when ready
# resource "openstack_networking_floatingip_v2" "myip" {
#   pool = "External"
# }

# resource "openstack_compute_floatingip_associate_v2" "myip" {
#   floating_ip = openstack_networking_floatingip_v2.myip.address
#   instance_id = openstack_compute_instance_v2.wordpress.id
#   fixed_ip    = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
# }

## Wordpress network and subnet if needed
# resource "openstack_networking_network_v2" "wordpress" {
#   name           = "wordpress"
#   external       = "false"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "wordpress_subnet" {
#   name       = "wordpress_subnet"
#   network_id = "${openstack_networking_network_v2.wordpress.id}"
#   cidr       = "192.168.199.0/24"
#   ip_version = 4
# }