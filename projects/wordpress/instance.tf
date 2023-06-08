resource "openstack_compute_instance_v2" "wordpress" {
  name            = "wordpress"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.c2.medium"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data       = data.template_cloudinit_config.cloud-config.rendered

  network {
    name = "wordpress"
  }

  # provisioner "file" {
  #   source      = "${path.module}/ansible/templates/nginx-domain"
  #   destination = "/etc/nginx/sites-available/nginx-domain"
  # }

  # connection {
  #   type        = "ssh"
  #   user        = "drew"
  #   private_key = file("../../auth/wordpress.pem")
  #   host        = "${self.access_ip_v4}"
  # }
  # depends_on = [ openstack_networking_network_v2.wordpress, openstack_networking_subnet_v2.wordpress_subnet ]
}

output "wordpress_ip" {
  value = openstack_compute_instance_v2.wordpress.network.0.fixed_ip_v4
}