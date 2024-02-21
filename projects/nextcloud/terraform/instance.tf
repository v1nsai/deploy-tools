resource "openstack_compute_instance_v2" "nextcloud" {
  name            = "nextcloud-dev"
  image_name      = "nextcloud-dev"
  # image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.st2.medium"
  key_pair        = "nextcloud"
  # security_groups = [ "default", "SSH ingress", "HTTP ingress", "HTTPS ingress", "nextcloud-talk" ] # prod names
  security_groups = [ "default", "ssh-ingress", "http-ingress", "https-ingress" ]
  user_data       = local.cloud_config

  network {
    name = "nextcloud"
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.85"
  instance_id = openstack_compute_instance_v2.nextcloud.id
}
