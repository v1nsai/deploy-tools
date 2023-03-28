# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

data "external" "env" {
  program = ["${path.module}/tf-env.sh"]
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = data.external.env.result["user_name"]
  tenant_name = data.external.env.result["tenant_name"]
  password    = data.external.env.result["password"]
  auth_url    = data.external.env.result["auth_url"]
  region      = data.external.env.result["region"]
}

# # Create a web server
resource "openstack_compute_instance_v2" "basic" {
  name            = "server"
  image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
  flavor_id       = "alt.st1.small"
  key_pair        = "dr_ew"
  security_groups = ["default", "ssh-ingress"]

  metadata = {
    this = "that"
  }

  network {
    name = "External"
  }
}
