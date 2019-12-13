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

resource "aws_iam_role" "s3-reads" {
  name = "spark-application-s3-reads"

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
  role       = "${aws_iam_role.s3-reads.name}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}
