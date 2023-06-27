resource "openstack_compute_secgroup_v2" "plex" {
  name        = "plex"
  description = "Plex Media Server Security Group"

    # Create an ingress rule for each port plex media server uses
    rule {
        from_port   = 32400
        to_port     = 32400
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 1900
        to_port     = 1900
        ip_protocol = "udp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 5353
        to_port     = 5353
        ip_protocol = "udp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 8324
        to_port     = 8324
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 32410
        to_port     = 32414
        ip_protocol = "udp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 32469
        to_port     = 32469
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }
}