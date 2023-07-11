data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/wordpress.pub")
}

data "local_file" "github_anonymous_pub" {
    filename = pathexpand("~/.ssh/github_anonymous.pub")
}

data "local_file" "ssl_key" {
    filename = "${path.cwd}/auth/doctor-ew.com-cloudflare.key"
}

data "local_file" "ssl_crt" {
    filename = "${path.cwd}/auth/doctor-ew.com-cloudflare.crt"
}