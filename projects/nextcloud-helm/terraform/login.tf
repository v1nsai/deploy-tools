terraform {
  # required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
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

# Configure providers
provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
}