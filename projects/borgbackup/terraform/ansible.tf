# resource "ansible_playbook" "backupserver" {
#   playbook   = "${path.cwd}/projects/borgbackup/ansible/backupserver.yaml"
#   name       = "backupserver"
#   replayable = true
#   depends_on = [ openstack_compute_instance_v2.borgbackup, openstack_compute_floatingip_associate_v2.fip_1 ]
#   verbosity  = 6
#   check_mode = false
#   diff_mode  = false

#   extra_vars = {
#     user        = "localadmin"
#     private-key = "${pathexpand("~/.ssh/borgbackup")}"
#     backuphost  = openstack_compute_floatingip_associate_v2.fip_1.floating_ip
#   }
# }

# output "temp_inventory_file" {
#   value = ansible_playbook.backupserver.temp_inventory_file
# }

# output "args" {
#   value = ansible_playbook.backupserver.args
# }

# # resource "null_resource" "ansible_provisioner" {
# #   depends_on = [ openstack_compute_instance_v2.borgbackup, openstack_compute_floatingip_associate_v2.fip_1, ansible_playbook.backupserver ]

# #   triggers = {
# #     inventory_file = ansible_playbook.backupserver.temp_inventory_file
# #   }

# #   provisioner "local-exec" {
# #     command = "ansible-playbook --inventory '${openstack_compute_floatingip_associate_v2.fip_1.floating_ip},' --user backup --private-key ~/.ssh/borgbackup ${null_resource.ansible_provisioner.triggers.inventory_file.content}"
# #   }
# # }

# # ${path.cwd}/projects/borgbackup/ansible/backupserver.yaml
