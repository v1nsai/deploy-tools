packer {
  required_plugins {
    openstack = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

variable "user_name" {
  type      = string
  sensitive = true
}
variable "tenant_name" {
  type      = string
  sensitive = true
}
variable "password" {
  type      = string
  sensitive = true
}
variable "auth_url" {
  type      = string
  sensitive = true
}
