resource "openstack_compute_instance_v2" "dashboards" {
  name            = "dashboards"
  image_id      = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.st2.large"
  key_pair        = "dashboards"
  security_groups = ["default", "ssh-ingress", "http-ingress", "https-ingress"]
  user_data       = local.cloud_config

  network {
    name = "dashboards"
  }

  depends_on = [ openstack_networking_subnet_v2.dashboards_subnet ]
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_associate" {
  floating_ip = "216.87.32.38" # openstack_networking_floatingip_v2.floating_ip.address
  instance_id = openstack_compute_instance_v2.dashboards.id
  fixed_ip    = openstack_compute_instance_v2.dashboards.network.0.fixed_ip_v4
}
