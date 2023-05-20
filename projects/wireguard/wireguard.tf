terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Configure before running
variable "network_name" {
  type = string
  default = "wordpress"
}

# auth/auth.tfvars
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

# resource "openstack_compute_instance_v2" "wireguard" {
#   name            = "wireguard"
#   image_id        = "5557a492-f9f9-4a8a-98ec-5f642b611d23"
#   flavor_name     = "alt.c2.medium"
#   key_pair        = "wireguard"
#   security_groups = ["default", "ssh-ingress"]
#   # user_data       = file("cloud-config.yaml")

#   network {
#     name = "wordpress"
#   }
# }

# resource "openstack_networking_floatingip_v2" "external_ip" {
#   pool = "External"
# }

# resource "openstack_compute_floatingip_associate_v2" "external_ip_associate" {
#   floating_ip = "${openstack_networking_floatingip_v2.external_ip.address}"
#   instance_id = "${openstack_compute_instance_v2.wireguard.id}"
#   fixed_ip    = "${openstack_compute_instance_v2.wireguard.network.0.fixed_ip_v4}"
# }

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = <<EOT
      # Clone repo if necessary, remove generated configs and copy server configs
      git clone https://github.com/trailofbits/algo.git ../algo || true
      cp -f projects/wireguard/config.cfg ../algo/config.cfg
      cp -f projects/wireguard/requirements.txt ../algo/requirements.txt
      rm -rf projects/wireguard/configs || true

      # Configure environment, openstacksdk needs to be manually downgraded which requires python < 3.11, 3.9 confirmed working
      python3 -m pip install --user --upgrade virtualenv
      python3 -m virtualenv --python="$(command -v python3)" ../algo/env &&
        source ../algo/.env/bin/activate &&
        python3 -m pip install -U pip virtualenv &&
        python3 -m pip install -r projects/wireguard/requirements.txt
      EOT
    working_dir = "${path.cwd}"
  }
}

resource "ansible_playbook" "playbook" {
  playbook   = "../algo/main.yml"
  name       = "wireguard"
  replayable = false

  extra_vars = {
    var_a = "Some variable"
    var_b = "Another variable"
  }
}
