resource "openstack_compute_instance_v2" "openproject" {
  name            = "openproject"
  # image_name      = "openproject" # Wordpress-latest-Ubuntu_22.04
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st2.medium"
  key_pair        = "openproject"
  # security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  security_groups = [ "default", "SSH ingress", "HTTP ingress", "HTTPS ingress", "nextcloud-talk" ]
  user_data       = local.cloud_config

  network {
    name = "techigsite" # prod
    # name = "nextcloud" # dev
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.8" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.openproject.id
  fixed_ip    = openstack_compute_instance_v2.openproject.network.0.fixed_ip_v4
}
