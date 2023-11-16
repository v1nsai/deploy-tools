resource "openstack_containerinfra_clustertemplate_v1" "nextcloud-helm" {
  name                  = "nextcloud-helm"
  image                 = "f6ed7a8b-f808-4cfe-ab9d-0a492e14f2ff"
  coe                   = "kubernetes"
  flavor                = "alt.c2.medium"
  master_flavor         = "alt.c2.medium"
  dns_nameserver        = "1.1.1.1"
  docker_storage_driver = "overlay"
  docker_volume_size    = 10
  volume_driver         = "cinder"
  network_driver        = "calico"
  server_type           = "vm"
  external_network_id   = "b1d12129-bbfc-4482-a5d2-c20458459ddc"
  # fixed_network         = "nextcloud-testing"
  # fixed_subnet          = "nextcloud-testing_subnet"
  # master_lb_enabled     = false
  # floating_ip_enabled   = false


  labels = {
    kube_dashboard_enabled           = "True"
    # prometheus_monitoring            = "True"
    # influx_grafana_dashboard_enabled = "True"
    # csi_snapshotter_tag              = "v4.0.0"
    # kube_tag                         = "v1.23.3-rancher1"
    cloud_provider_enabled           = "True"
    # hyperkube_prefix                 = "docker.io/rancher/"
    # ingress_controller               = "octavia"
    master_lb_floating_ip_enabled    = "False"
  }
}