# Adapted from https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_test_fixture/main.tf
terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "eu-west-1"
}

provider "random" {
  version = "= 1.3.1"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all *nix machines"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "spark-eks-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "2.2.0"
  cluster_name = "spark-eks"
  subnets      = ["${module.vpc.private_subnets}"]
  vpc_id       = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_desired_capacity = 2
      asg_min_size = 2
      asg_max_size  = 2
    },
  ]
}
