resource "openstack_containerinfra_cluster_v1" "nextcloud_cluster" {
  name                = "nextcloud_cluster"
  cluster_template_id = data.openstack_containerinfra_clustertemplate_v1.nextcloud_cluster_template.id
  master_count        = 1
  node_count          = 1
  keypair             = "nextcloud"
  depends_on = [ openstack_containerinfra_clustertemplate_v1.nextcloud_cluster_template ]
}

data "openstack_containerinfra_clustertemplate_v1" "nextcloud_cluster_template" {
  name = "nextcloud_cluster_template"
  depends_on = [ openstack_containerinfra_clustertemplate_v1.nextcloud_cluster_template ]
}
