data "template_cloudinit_config" "cloud-config" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-config.rendered
  }
}

data "template_file" "cloud-config" {
  template = file("cloud-config.yaml")
}