variable "aws_access_key_id" { type = string }
variable "aws_secret_access_key" { type = string }
variable "aws_region" { type = string }
variable "aws_default_output_format" { type = string }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}