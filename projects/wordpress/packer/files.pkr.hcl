locals {
  ssh_key    = file(pathexpand("~/.ssh/wordpress"))
  ssh_pubkey = file(pathexpand("~/.ssh/wordpress.pub"))
}
