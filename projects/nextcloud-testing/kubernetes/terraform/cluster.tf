resource "openstack_containerinfra_cluster_v1" "nextcloud-k8s" {
  name                = "nextcloud-k8s"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.nextcloud-k8s.id
  master_count        = "1"
  node_count          = "2"
  keypair             = "nextcloud"
}
