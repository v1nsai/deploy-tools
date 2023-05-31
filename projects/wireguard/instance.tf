resource "openstack_compute_instance_v2" "wireguard" {
  name            = "wireguard"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.c2.medium"
  key_pair        = "wireguard"
  security_groups = ["default", "ssh-ingress", "wireguard-security_group"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "kubeflow"
  }
  # depends_on = [ openstack_networking_subnet_v2.kubeflow_subnet ]
#   provisioner "file" {
#     source      = "config.cfg"
#     destination = "/opt/config.cfg"
#   }
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.wireguard.id}"
  fixed_ip    = "${openstack_compute_instance_v2.wireguard.network.0.fixed_ip_v4}"
}