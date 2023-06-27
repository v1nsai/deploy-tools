resource "openstack_compute_instance_v2" "plex" {
  name            = "plex"
  image_name      = "ubuntu-jammy-server-cloudimg-amd64"
  flavor_name     = "m1.medium"
  key_pair        = "plex"
  security_groups = ["default", "ssh-ingress", "${openstack_compute_secgroup_v2.plex.name}"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "plex"
  }
  # network {
  #   name = "shared"
  # }
  depends_on = [ openstack_networking_network_v2.plex, openstack_networking_subnet_v2.plex_subnet ]
}