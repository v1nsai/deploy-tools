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

# resource "openstack_networking_network_v2" "kubeflow" {
#   name           = "kubeflow"
#   external       = "false"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "kubeflow_subnet" {
#   name       = "kubeflow_subnet"
#   network_id = "${openstack_networking_network_v2.kubeflow.id}"
#   cidr       = "192.168.199.0/24"
#   ip_version = 4
# }

resource "openstack_containerinfra_clustertemplate_v1" "kubeflow-template" {
  name                  = "kubeflow-template"
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
  keypair_id            = "kubeflow"
  docker_volume_size    = "10"
  fixed_network         = "kubeflow"
  fixed_subnet          = "kubeflow_subnet"
  # https_proxy =
  # master_lb_floatingip_enabled = true

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

resource "openstack_containerinfra_cluster_v1" "kubeflow" {
  name                = "kubeflow"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.kubeflow-template.id
  master_count        = 1
  node_count          = 1
  keypair             = "kubeflow"
  create_timeout      = 60
}