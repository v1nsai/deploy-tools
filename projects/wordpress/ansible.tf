resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/wordpress.yml"
  }
}

locals {
  ansible_inventory = <<-EOF
[wordpress]
server1 ansible_host="${resource.openstack_compute_instance_v2.wordpress.access_ip_v4}" ansible_user=drew ansible_ssh_private_key_file="${path.module}/../../auth/wordpress"      
  EOF
}

resource "local_file" "inventory" {
    content = local.ansible_inventory
    filename = "${path.module}/ansible/inventory.ini"
}