data "local_file" "private-key" {
    filename = pathexpand("~/.ssh/devnode")
}

data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/devnode.pub")
}