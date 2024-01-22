terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

# Configure providers
provider "openstack" {
  user_name   = data.external.env.result["OS_USERNAME"]
  tenant_name = data.external.env.result["OS_PROJECT_NAME"]
  password    = data.external.env.result["OS_PASSWORD"]
  auth_url    = data.external.env.result["OS_AUTH_URL"]
}

data "external" "env" {
  program = ["${path.cwd}/scripts/envvars-to-terraform.sh"]
}