data "openstack_networking_network_v2" "wordpress" {
  name = "wordpress"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

data "openstack_networking_secgroup_v2" "ssh-ingress" {
  name = "ssh-ingress"
}

data "openstack_networking_secgroup_v2" "http-ingress" {
  name = "http-ingress"
}

data "openstack_networking_secgroup_v2" "https-ingress" {
  name = "https-ingress"
}
