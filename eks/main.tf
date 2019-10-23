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

locals {
  cluster_name = "spark-eks"
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

data "aws_caller_identity" "current" {}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  #https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/4.0.2
  version                     = "4.0.2"
  cluster_name                = "${local.cluster_name}"
  subnets                     = ["${module.vpc.private_subnets}"]
  vpc_id                      = "${module.vpc.vpc_id}"
  manage_aws_auth             = false
  write_aws_auth_config       = false
  manage_worker_iam_resources = false
  write_kubeconfig            = false

  worker_groups = [
    {
      name                      = "spark_default"
      instance_type             = "m4.large"
      kubelet_extra_args        = "--node-labels 'kubernetes.io/type=spark,kubernetes.io/type=spark_default'"
      asg_desired_capacity      = 1
      asg_min_size              = 1
      asg_max_size              = 2
      iam_instance_profile_name = "${aws_iam_instance_profile.workers.id}"
      key_name                  = "maintenance-key"

      tags = {
        type = "spark"
      }
    },
    {
      name                      = "kiam"
      instance_type             = "m4.large"
      kubelet_extra_args        = "--node-labels 'kubernetes.io/type=kiam'"
      asg_desired_capacity      = 1
      asg_desired_capacity      = 1
      asg_max_size              = 1
      iam_instance_profile_name = "${aws_iam_instance_profile.kiam.id}"
      key_name                  = "maintenance-key"

      tags = {
        type = "kiam"
      }
    },
  ]

  worker_group_count = "2"
}

module "node-config" {
  source = "./node-config"

  # It is not possible to get the workers_arn from the module -- this is only possible if the module is generating them.
  worker_role_arn = ["${aws_iam_role.workers.arn}", "${aws_iam_role.kiam_node.arn}"]
  cluster_name    = "${module.eks.cluster_id}"
  account_id      = "${data.aws_caller_identity.current.account_id}"
}
