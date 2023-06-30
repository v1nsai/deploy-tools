resource "null_resource" "create_directory_with_permissions" {

  triggers = {
    instance_id = "${openstack_compute_instance_v2.wordpress.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/wp-deploy",
      "sudo chown -R localadmin:localadmin /opt/wp-deploy",
      "sudo chmod -R 775 /opt/wp-deploy"
    ]

    connection {
      type        = "ssh"
      user        = "localadmin"
      private_key = file(pathexpand("~/.ssh/wordpress"))
      host        = openstack_networking_floatingip_v2.floating_ip.address
    }
  }
}

resource "null_resource" "upload-and-execute-file" {

  triggers = {
    instance_id = "${openstack_compute_instance_v2.wordpress.id}"
    create_directory_with_permissions = "${null_resource.create_directory_with_permissions.id}"
  }

  provisioner "file" {
    source = "${path.cwd}/projects/wordpress/install.sh"
    destination = "/opt/wp-deploy/install.sh"
  }

  provisioner "file" {
    source = pathexpand("~/.ssh/github_anonymous")
    destination = "/home/localadmin/.ssh/id_rsa"
  }

  provisioner "file" {
    source = pathexpand("~/.ssh/github_anonymous.pub")
    destination = "/home/localadmin/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source = "../ansible/inventory.yml"
    destination = "/opt/wp-deploy/ansible/inventory.yml"
  }

  provisioner "file" {
    source = "../ansible/deploy.yml"
    destination = "/opt/wp-deploy/ansible/deploy.yml"
  }

  connection {
    type        = "ssh"
    user        = "localadmin"
    private_key = file(pathexpand("~/.ssh/wordpress"))
    host        = openstack_networking_floatingip_v2.floating_ip.address
  }

  depends_on = [ null_resource.create-directory-with-permissions ]
}