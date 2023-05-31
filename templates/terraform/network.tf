resource "openstack_networking_network_v2" "kubeflow" {
  name           = "kubeflow"
  external       = "false"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "kubeflow_subnet" {
  name       = "kubeflow_subnet"
  network_id = "${openstack_networking_network_v2.kubeflow.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "kubeflow_router" {
  name                = "kubeflow_router"
  admin_state_up      = true
  external_network_id = "b1d12129-bbfc-4482-a5d2-c20458459ddc"
}

resource "openstack_networking_router_interface_v2" "kubeflow_subnet_interface" {
  router_id = "${openstack_networking_router_v2.kubeflow_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.kubeflow_subnet.id}"
}