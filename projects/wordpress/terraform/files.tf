# data "local_file" "nginx-domain" {
#     filename = "${path.module}/ansible/templates/nginx-domain"
# }

data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/wordpress.pub")
}

# data "local_file" "github_anonymous" {
#     filename = pathexpand("~/.ssh/github_anonymous")
# }

data "local_file" "github_anonymous_pub" {
    filename = pathexpand("~/.ssh/github_anonymous.pub")
}

# data "local_file" "install_sh" {
#     filename = "install.sh"
# }

# data "local_file" "ssl-cert" {
#     filename = "../../auth/ssl.crt"
# }

# data "local_file" "ssl-key" {
#     filename = "../../auth/ssl.key"
# }

# data "local_file" "ansible-inventory" {
#     filename = "ansible/inventory.yml"
# }

# data "local_file" "ansible-playbook" {
#     filename = "ansible/deploy.yml"
# }