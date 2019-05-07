terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "eu-west-1"
}

resource "aws_key_pair" "maintenance" {
  key_name   = "maintenance-key"
  public_key = "${var.maintenance_public_key}"
}
