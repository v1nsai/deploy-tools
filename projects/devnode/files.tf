data "local_sensitive_file" "private-key" {
    filename = pathexpand("~/.ssh/devnode")
}

data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/devnode.pub")
}

data "local_file" "private-key" {
    filename = pathexpand("~/.ssh/devnode")
}

data "local_sensitive_file" "alterncloud-env" {
    filename = "${path.cwd}/auth/alterncloud.env"
}
