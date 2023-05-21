terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
    ansible = {
      version = "1.1.0"
      source  = "ansible/ansible"
    }
  }
}

# Configure before running
variable "network_name" {
  type    = string
  default = "wordpress"
}

# auth/auth.tfvars
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

resource "null_resource" "pre-deploy" {
  provisioner "local-exec" {
    command     = "projects/wireguard/pre-deploy.sh"
    working_dir = path.cwd
    interpreter = ["bash"]
  }
}

resource "null_resource" "deploy" {
  provisioner "local-exec" {
    command     = "projects/wireguard/deploy.sh"
    working_dir = path.cwd
    interpreter = ["bash"]
  }
}

# resource "ansible_playbook" "playbook" {
#   playbook                = "projects/wireguard/algo/main.yml"
#   name                    = "wireguard"
#   replayable              = false
#   verbosity               = 6
#   ansible_playbook_binary = "ansible-playbook"

#   check_mode = false
#   diff_mode = false 

#   depends_on = [ null_resource.pre-deploy ]
#   timeouts {
#     create = "30m"
#   }

#   extra_vars = {
#     provider           = "openstack"
#     server_name        = "wireguard"
#     ondemand_cellular  = false
#     ondemand_wifi      = false
#     dns_adblocking     = true
#     ssh_tunneling      = false
#     store_pki          = true
#     ansible_connection = "local"
#   }
# }
