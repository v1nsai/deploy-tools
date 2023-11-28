resource "openstack_compute_instance_v2" "devbox" {
  name            = "devbox"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st1.small"
  key_pair        = "devbox"
  security_groups = ["default", "ssh-ingress"]
  user_data       = local.cloud-init

  network {
    name = "nextcloud"
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "216.87.32.71"
  instance_id = openstack_compute_instance_v2.devbox.id
  # fixed_ip    = openstack_compute_instance_v2.devbox.access_ip_v4
}
