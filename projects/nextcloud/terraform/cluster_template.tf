resource "openstack_containerinfra_clustertemplate_v1" "nextcloud_cluster_template" {
  name                  = "nextcloud_cluster_template"
  image                 = "f6ed7a8b-f808-4cfe-ab9d-0a492e14f2ff" # Fedora CoreOS 37.20230205.3.0-stable
  coe                   = "swarm"
  flavor                = "alt.st2.small"
  master_flavor         = "alt.st2.small"
#   dns_nameserver        = "1.1.1.1"
  docker_storage_driver = "overlay2"
  docker_volume_size    = 10
  volume_driver         = "rexray"
  network_driver        = "flannel"
  server_type           = "vm"
  master_lb_enabled     = false
  floating_ip_enabled   = false
  fixed_network         = resource.openstack_networking_network_v2.nextcloud_network.name
  fixed_subnet          = resource.openstack_networking_subnet_v2.nextcloud_subnet.name
  external_network_id   = "b1d12129-bbfc-4482-a5d2-c20458459ddc"

  labels = {
    cloud_provider_enabled = true
    # auto_healing_enabled = false
    auto_scaling_enabled = true
    autoscaler_tag = "v1.23.0"
  }

  # k8s labels
  # labels = {
  #   kube_dashboard_enabled = "true"
  #   cinder_csi_enabled = "true"
  #   kube_tag = "v1.23.3-rancher1"
  #   cloud_provider_enabled = "true"
  #   hyperkube_prefix = "docker.io/rancher/"
  #   csi_snapshotter_tag = "v4.0.0"
  #   # ingress_controller = "octavia"
  #   # kubelet_options = "--node-labels magnum.openstack.org/role=ingress"
  # }
}