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

# used `_node` in it's name, because this is also used within the default policy names.
data "aws_iam_role" "kiam_node" {
  name = "${local.cluster_name}_kiam_node"
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
        "AWS": "${data.aws_iam_role.kiam_node.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kiam_node" {
  name = "kiam-node"
  role = "${data.aws_iam_role.kiam_node.name}"

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

# data "aws_eks_cluster" "this" {
#   name = "${var.cluster_name}"
# }
#
# data "aws_eks_cluster_auth" "this" {
#   name = "${data.aws_eks_cluster.this.name}"
# }
#
# provider "kubernetes" {
#   config_path = "../kubeconfig"
# }
#
# data "template_file" "ca_issuer_certs" {
#   template = "${file("${path.module}/templates/ca-issuer-certs.yaml")}"
# }
#
# resource "null_resource" "ca_issuer_certs" {
#   triggers = {
#     manifest_sha1 = "${sha1("${data.template_file.ca_issuer_certs.rendered}")}"
#   }
#
#   provisioner "local-exec" {
#     command = "kubectl apply -f -<<EOF\n${data.template_file.ca_issuer_certs.rendered}\nEOF"
#   }
# }
