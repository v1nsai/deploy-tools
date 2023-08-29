data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/wordpress.pub")
}

data "local_file" "github_anonymous_pub" {
    filename = pathexpand("~/.ssh/github_anonymous.pub")
}
