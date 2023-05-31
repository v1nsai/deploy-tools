resource "openstack_compute_instance_v2" "instance" {
  name            = "instance"
  image_id        = "012cb821-5b05-48a5-b33e-89040561fbc4" # Debian 11
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }
  # depends_on = [ openstack_networking_floatingip_v2.myip, openstack_compute_floatingip_associate_v2.myip ]
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
  fixed_ip    = "${openstack_compute_instance_v2.instance.access_ip_v4}"
}