# Adapted from https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_test_fixture/main.tf
terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "eu-west-1"
}

locals {
  cluster_name = "spark-eks"
}

resource "aws_iam_role" "kiam_server" {
  name        = "kiam-server"
  description = "Role the Kiam Server process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_role.server_node.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kiam_server" {
  name        = "kiam-server"
  description = "Policy for the Kiam Server process"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "kiam_server" {
  name       = "kiam-server-policy"
  roles      = ["${aws_iam_role.kiam_server.name}"]
  policy_arn = "${aws_iam_policy.kiam_server.arn}"
}

# used `_node` in it's name, because this is also used within the default policy names.
data "aws_iam_role" "server_node" {
  name = "${local.cluster_name}_kiam_node"
}
resource "aws_iam_role_policy" "server_node" {
  name = "kiam-server-node"
  role = "${data.aws_iam_role.server_node.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "${aws_iam_role.kiam_server.arn}"
    }
    ]
  }
EOF
}
