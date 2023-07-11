resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_name      = "wordpress"
  flavor_name     = "alt.st1.nano"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
}

data "openstack_images_image_ids_v2" "wordpress_image" {
  name_regex = "^wordpress$"
} 

# resource "openstack_networking_floatingip_v2" "floating_ip" {
#   pool = "External"
# }

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.102" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.wordpress.id
  fixed_ip    = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}
