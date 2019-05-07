terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "eu-west-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "eks-demo-app-bucket-randomword-clown"
  region = "eu-west-1"
  acl    = "private"

  tags {
    name      = "demo-bucket"
    Terraform = "True"
  }
}

resource "aws_s3_bucket_object" "demo" {
  key     = "demo.csv"
  bucket  = "${aws_s3_bucket.bucket.id}"
  content = "blaat"
}

data "aws_iam_role" "kiam_server" {
  name = "kiam_server"
}

resource "aws_iam_role" "read" {
  name = "demoapp-read"

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

# Create the EMR policies
data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_s3_bucket.bucket.arn}",
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name        = "s3_read"
  description = ""
  path        = "/"
  policy      = "${data.aws_iam_policy_document.s3.json}"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.read.name}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}
