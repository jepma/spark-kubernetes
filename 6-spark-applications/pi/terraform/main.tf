terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "kiam_server" {
  name = "kiam-server"
}

resource "aws_iam_role" "read" {
  name = "spark-application-pi"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                  "Service": "ec2.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          },
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "AWS": "${data.aws_iam_role.kiam_server.arn}"
              },
              "Action": "sts:AssumeRole"
            }
      ]
}
EOF
}
