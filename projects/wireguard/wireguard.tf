terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

variable "user_name" {
  type = string
}

variable "tenant_name" {
  type = string
}

variable "password" {
  type = string
}

variable "auth_url" {
  type = string
}

provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
}

resource "openstack_compute_instance_v2" "wireguard" {
  name            = "wireguard"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_name     = "alt.c2.medium"
  key_pair        = "wireguard"
  security_groups = ["default", "ssh-ingress"]
  user_data       = file("cloud-config.yaml")

  network {
    name = "wordpress"
  }
}

resource "openstack_networking_floatingip_v2" "external_ip" {
  pool = "External"
}

resource "openstack_compute_floatingip_associate_v2" "external_ip_associate" {
  floating_ip = "${openstack_networking_floatingip_v2.external_ip.address}"
  instance_id = "${openstack_compute_instance_v2.wireguard.id}"
  fixed_ip    = "${openstack_compute_instance_v2.wireguard.network.0.fixed_ip_v4}"
}

# resource "openstack_blockstorage_volume_v2" "wireguard-volume" {
#   name = "wireguard-volume"
#   size = 10
# }

# resource "openstack_compute_volume_attach_v2" "attached" {
#   instance_id = "${openstack_compute_instance_v2.myinstance.id}"
#   volume_id   = "${openstack_blockstorage_volume_v2.myvol.id}"
# }