resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_id        = "012cb821-5b05-48a5-b33e-89040561fbc4" # Debian 11
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }

  provisioner "file" {
    source      = "postdeploy.zip"
    destination = "/tmp/postdeploy.zip"
  }

  connection {
    type        = "ssh"
    user        = "drew"
    private_key = file("../../auth/wordpress.pem")
    port        = 1355
    host        = "${self.access_ip_v4}"
  }
  # depends_on = [ openstack_networking_network_v2.wordpress, openstack_networking_subnet_v2.wordpress_subnet ]
}

output "wordpress_ip" {
  value = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}

output "wordpress_ip_again" {
  value = openstack_compute_instance_v2.wordpress.access_ip_v4
}