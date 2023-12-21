resource "openstack_containerinfra_cluster_v1" "nextcloud-helm" {
  name                = "nextcloud-helm"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.nextcloud-helm.id
  master_count        = 1
  node_count          = 2
  keypair             = "nextcloud"
  create_timeout      = 30
}
