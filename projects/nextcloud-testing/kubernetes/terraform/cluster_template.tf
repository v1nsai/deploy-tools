resource "openstack_containerinfra_clustertemplate_v1" "nextcloud-k8s" {
  name                  = "nextcloud-k8s"
  image                 = "Fedora CoreOS 37.20230303.3.0"
  coe                   = "kubernetes"
  flavor                = "alt.st1.small"
  master_flavor         = "alt.st1.medium"
  docker_volume_size    = 10
  volume_driver         = "cinder"
  network_driver        = "calico"
  external_network_id   = data.openstack_networking_network_v2.External.id
  server_type           = "vm"
  master_lb_enabled     = false
  floating_ip_enabled   = false

  labels = {
    kube_dashboard_enabled           = true
    # prometheus_monitoring            = true
    # influx_grafana_dashboard_enabled = true
    csi_snapshotter_tag              = "v4.0.0"
    kube_tag                         = "v1.23.3-rancher1"
    cloud_provider_enabled           = true
    hyperkube_prefix                 = "docker.io/rancher"
    ingress_controller               = "octavia"
    master_lb_floating_ip_enabled    = false
  }
}

data "openstack_networking_network_v2" "External" {
  name = "External"
}