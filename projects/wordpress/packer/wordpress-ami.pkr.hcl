source "amazon-instance" "basic-example" {
  region = "us-east-1"
  source_ami = "ami-d9d6a6b0"
  instance_type = "m1.small"
  ssh_username = "ubuntu"

  account_id = "0123-4567-0890"
  s3_bucket = "packer-images"
  x509_cert_path = "x509.cert"
  x509_key_path = "x509.key"
  x509_upload_path = "/tmp"
}

build {
  source "sources.amazon-instance.basic-example" {
    ami_name = "packer-quick-start {{timestamp}}"
  }
}
