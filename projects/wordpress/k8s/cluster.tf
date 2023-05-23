terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
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

resource "openstack_networking_network_v2" "wordpress" {
  name           = "wordpress"
  external       = "false"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "wordpress_subnet" {
  name       = "wordpress_subnet"
  network_id = "${openstack_networking_network_v2.wordpress.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_containerinfra_clustertemplate_v1" "wordpress-template" {
  name                  = "wordpress-template"
  image                 = "f6ed7a8b-f808-4cfe-ab9d-0a492e14f2ff"
  coe                   = "kubernetes"
  flavor                = "alt.gp2.large"
  master_flavor         = "alt.gp2.large"
  dns_nameserver        = "1.1.1.1,1.0.0.1"
  docker_storage_driver = "overlay"
  server_type           = "vm"
  volume_driver         = "cinder"
  master_lb_enabled     = false
  floating_ip_enabled   = true
  external_network_id   = "External"
  registry_enabled      = "false"
  keypair_id            = "wordpress"
  docker_volume_size    = "10"
  # fixed_network = "${openstack_networking_network_v2.wordpress.id}"
  # fixed_subnet  = "${openstack_networking_subnet_v2.wordpress_subnet.id}"
  # https_proxy =

  labels = {
    kube_dashboard_enabled        = "true"
    cinder_csi_enabled            = "true"
    kube_tag                      = "v1.23.3-rancher1"
    cloud_provider_enabled        = "true"
    hyperkube_prefix              = "docker.io/rancher/"
    csi_snapshotter_tag           = "v4.0.0"
    master_lb_floating_ip_enabled = false
    floating_ip_enabled           = true
    # ingress_controller            = "octavia"
    # kubelet_options               = "--node-labels magnum.openstack.org/role=ingress"
  }
}

resource "openstack_containerinfra_cluster_v1" "wordpress" {
  name                = "wordpress"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.wordpress-template.id
  master_count        = 1
  node_count          = 1
  keypair             = "wordpress"
  create_timeout      = 60
}

# resource "null_resource" "deploy" {
#   provisioner "local-exec" {
#     command     = "projects/wireguard/deploy.sh"
#     working_dir = path.cwd
#     interpreter = ["bash"]
#   }
#   depends_on = [ openstack_containerinfra_cluster_v1.wordpress ] 
# }

resource "null_resource" "pre-deploy" {
  provisioner "local-exec" {
    command     = "projects/wireguard/pre-deploy.sh"
    working_dir = path.cwd
    interpreter = ["bash"]
  }
  depends_on = [ openstack_containerinfra_cluster_v1.wordpress ]
  replayable = true
}

# resource "ansible_host" "localhost" {
#   name   = "localhost"
# }

resource "ansible_playbook" "playbook" {
  playbook                = "projects/wireguard/algo/main.yml"
  name                    = "wireguard"
  replayable              = false
  verbosity               = 6
  ansible_playbook_binary = "ansible-playbook"

  check_mode = false
  diff_mode = false 

  depends_on = [ null_resource.pre-deploy, openstack_containerinfra_cluster_v1.wordpress ]
  timeouts {
    create = "30m"
  }

  extra_vars = {
    provider           = "openstack"
    server_name        = "wireguard"
    ondemand_cellular  = false
    ondemand_wifi      = false
    dns_adblocking     = true
    ssh_tunneling      = false
    store_pki          = true
    ansible_connection = "localhost"
    ansible_host       = "localhost"
    connection         = "localhost"
  }
}