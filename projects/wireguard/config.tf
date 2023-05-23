data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-config.rendered
  }

  part {
    filename     = "config.cfg"
    content      = data.local_file.cloud-config.content
  }
}

data "local_file" "cloud-config" {
  filename = "cloud-config.yaml"
}

data "template_file" "cloud-config" {
  template = file("cloud-config.yaml")
}