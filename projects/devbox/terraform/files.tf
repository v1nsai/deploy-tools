data "local_sensitive_file" "private-key" {
    filename = pathexpand("~/.ssh/devbox")
}

data "local_file" "ssh-pubkey" {
    filename = pathexpand("~/.ssh/devbox.pub")
}

data "local_sensitive_file" "openstack-env" {
    filename = "${path.cwd}/auth/openstack.env"
}
