resource "openstack_compute_instance_v2" "nextcloud" {
  # name            = "nextcloud-dev"
  name            = "nextcloud"
  # image_name      = "nextcloud-dev" # sandbox
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04 for prod
  flavor_name     = "alt.c2.large"
  key_pair        = "nextcloud"
  security_groups = [ "default", "SSH ingress", "HTTP ingress", "HTTPS ingress", "nextcloud-talk" ] # prod
  # security_groups = [ "default", "ssh-ingress", "http-ingress", "https-ingress" ] # sandbox
  user_data       = local.cloud_config

  network {
    # name = "nextcloud" # sandbox
    name = "" # prod
  }
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" { # sandbox
  # floating_ip = "216.87.32.85" # sandbox
  floating_ip = "216.87.32.36" # prod
  instance_id = openstack_compute_instance_v2.nextcloud.id
}
 
#  resource "openstack_compute_floatingip_v2" "floating_ip" { # prod
#    pool = "External"
#  }