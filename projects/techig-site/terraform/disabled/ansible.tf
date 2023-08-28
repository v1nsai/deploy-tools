# terraform {
#   after_hook {
#     commands = ["apply"]
#     working_dir = "${path.module}/ansible"
#     execute = ["ansible-playbook", "-i", "${path.module}/ansible/inventory.ini", "${path.module}/ansible/wordpress.yml"]
#   }
# }

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "echo \"${local.ansible_inventory}\" > ${path.module}/ansible/inventory.ini && ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/wordpress.yml"
  }
  
  triggers = {
    inventory_updated = "${resource.local_file.inventory.content_sha256}"
    instance_created = "${resource.openstack_compute_instance_v2.wordpress.id}"
#   always_run = "${timestamp()}"
  }
}

locals {
  ansible_inventory = <<-EOF
[wordpress]
server1 ansible_host="${resource.openstack_compute_instance_v2.wordpress.access_ip_v4}" ansible_user=drew ansible_ssh_private_key_file="../../auth/wordpress"
  EOF
}

resource "local_file" "inventory" {
  content = local.ansible_inventory
  filename = "${path.module}/ansible/inventory.ini"
  lifecycle {
    create_before_destroy = true
  }
}