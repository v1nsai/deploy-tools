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

resource "openstack_containerinfra_clustertemplate_v1" "wordpress-template" {
  name                  = "wordpress-template"
  image                 = "f6ed7a8b-f808-4cfe-ab9d-0a492e14f2ff"
  coe                   = "kubernetes"
  flavor                = "alt.gp2.large"
  master_flavor         = "alt.gp2.large"
  dns_nameserver        = "1.1.1.1,1.0.0.1"
  docker_storage_driver = "overlay"
  docker_volume_size    = 10
  server_type           = "vm"
  volume_driver         = "cinder"
  master_lb_enabled     = false
  floating_ip_enabled   = true
  external_network_id   = "External"
  #   https_proxy =

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
