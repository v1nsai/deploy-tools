resource "openstack_compute_instance_v2" "borgbackup" {
  name            = "borgbackup"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st1.nano"
  key_pair        = "borgbackup"
  user_data       = local.cloud_config
  security_groups = [ "default", "ssh-ingress" ]

  network {
    name = "nextcloud"
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "216.87.32.102" # register a floating IP and use it here
  instance_id = openstack_compute_instance_v2.borgbackup.id
}