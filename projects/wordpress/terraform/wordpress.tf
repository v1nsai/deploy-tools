resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_name      = "wordpress"
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  disk_size       = 10
  security_groups = ["default", "ssh-ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
}

data "openstack_images_image_ids_v2" "wordpress_image" {
  name_regex = "^wordpress$"
} 

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.wordpress.id
  fixed_ip    = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}
