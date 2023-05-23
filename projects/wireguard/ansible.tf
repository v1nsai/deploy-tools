##### Deploy by script.  It works.
# resource "null_resource" "deploy" {
#   provisioner "local-exec" {
#     command     = "projects/wireguard/deploy.sh"
#     working_dir = path.cwd
#     interpreter = ["bash"]
#   }
# }

##### Deploy by ansible provider.  It doesn't work.
# resource "null_resource" "pre-deploy" {
#   provisioner "local-exec" {
#     command     = "pre-deploy.sh"
#     working_dir = path.cwd
#     interpreter = ["bash"]
#   }
# }

# resource "ansible_playbook" "playbook" {
#   playbook                = "projects/wireguard/algo/main.yml"
#   name                    = "wireguard"
#   replayable              = false
#   verbosity               = 6
#   ansible_playbook_binary = "ansible-playbook"

#   check_mode = false
#   diff_mode = false 

#   depends_on = [ null_resource.pre-deploy ]
#   timeouts {
#     create = "30m"
#   }

#   extra_vars = {
#     provider           = "openstack"
#     server_name        = "wireguard"
#     ondemand_cellular  = false
#     ondemand_wifi      = false
#     dns_adblocking     = true
#     ssh_tunneling      = false
#     store_pki          = true
#     ansible_connection = "local"
#   }
# }
