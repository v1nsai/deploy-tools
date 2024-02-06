resource "openstack_networking_secgroup_v2" "nextcloud" {
  name        = "nextcloud-talk"
  description = "Nextcloud Talk"
}

resource "openstack_networking_secgroup_rule_v2" "nextcloud_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3478
  port_range_max    = 3478
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nextcloud.id
}

resource "openstack_networking_secgroup_rule_v2" "nextcloud_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 3478
  port_range_max    = 3478
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nextcloud.id
}