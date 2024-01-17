resource "openstack_compute_instance_v2" "nextcloud-testing" {
  name            = "nextcloud-testing"
  image_name      = "nextcloud-testing"
  flavor_name     = "alt.c2.large"
  key_pair        = "nextcloud-testing"
  security_groups = [ "default", "ssh-ingress", "http-ingress", "https-ingress" ]
  user_data       = local.cloud_config

  network {
    name = "nextcloud-testing"
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.33" 
  instance_id = openstack_compute_instance_v2.nextcloud-testing.id
  fixed_ip    = openstack_compute_instance_v2.nextcloud-testing.network.0.fixed_ip_v4
}
