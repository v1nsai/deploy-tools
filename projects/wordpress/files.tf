data "local_file" "nginx-domain" {
    filename = "${path.module}/ansible/templates/nginx-domain"
}

data "local_file" "ssh-pubkey" {
    filename = "${path.module}/../../auth/wordpress.pub"
}