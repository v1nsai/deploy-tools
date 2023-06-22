resource "openstack_compute_instance_v2" "instance" {
  name            = "instance"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23" # Ubuntu 22.04
  flavor_name     = "alt.c2.large"
  key_pair        = "wordpress"
  security_groups = ["default", "ssh-ingress", "HTTPS ingress", "HTTP ingress"]
  user_data = <<EOF
#cloud-config
ssh_pwauth: true
users:
  - name: localadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCX3ZnnojSpqi1R7CWmP7uVFU2fEd2uS4PYQpWC23ScmDGP7KFHeTJfMc6eMaAhbxfIXx2CFdsIhP5U58BFLmAxkUIM8lGnHgh1uME/aOMZokZrDhYnw0eaamVOg0rdKD/uaTo87ASoxpf0XYnrqcrYhFIQodxjsCC8pCU5Egjh9QDgHsniJ5vWEkxZGPQ4SXIj4txh8uXMI0mh57BWJRK0zJIDzZCxubtrOpWoQnVvg/ZV+Thgy0P9m7e8OHbaM3U/7p4DBd1MZ95jNwjefMeD5hR46T35rkR9w/ebEIKhGjz0UB2yRUZPOPqBzVfixYA6gfd5c1AhjluCyCqhLEMd Generated-by-Nova
  EOF

  network {
    name = "wordpress"
  }
  # depends_on = [ openstack_networking_floatingip_v2.myip, openstack_compute_floatingip_associate_v2.myip ]
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
  fixed_ip    = "${openstack_compute_instance_v2.instance.access_ip_v4}"
}