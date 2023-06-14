# data "local_file" "nginx-domain" {
#     filename = "${path.module}/ansible/templates/nginx-domain"
# }

data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/wordpress.pub")
}

data "local_file" "github_anonymous" {
    filename = pathexpand("~/.ssh/github_anonymous.base64")
}

data "local_file" "github_anonymous_pub" {
    filename = pathexpand("~/.ssh/github_anonymous.pub")
}

data "local_file" "install_sh" {
    filename = "install.sh.base64"
}