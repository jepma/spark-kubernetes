# #####
#
# resource "aws_iam_role" "server_node" {
#   name = "kiam_server_node"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": { "Service": "ec2.amazonaws.com"},
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_role_policy" "server_node" {
#   name = "kiam_server_node"
#   role = "${aws_iam_role.server_node.name}"
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "sts:AssumeRole"
#       ],
#       "Resource": "${aws_iam_role.server_role.arn}"
#     }
#     ]
#   }
# EOF
# }
#
# resource "aws_iam_role" "server_role" {
#   name        = "kiam_server"
#   description = "Role the Kiam Server process assumes"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${aws_iam_role.server_node.arn}"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_policy" "server_policy" {
#   name        = "kiam_server"
#   description = "Policy for the Kiam Server process"
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "sts:AssumeRole"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_policy_attachment" "server_policy_attach" {
#   name       = "kiam_server_attachment"
#   roles      = ["${aws_iam_role.server_role.name}"]
#   policy_arn = "${aws_iam_policy.server_policy.arn}"
# }

##################################################################################
##################################################################################
##################################################################################
##################################################################################
##################################################################################
##################################################################################

locals {
  cluster_name = "spark-eks"
}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kiam" {
  name_prefix           = "${local.cluster_name}_kiam_node"
  assume_role_policy    = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
  permissions_boundary  = ""
  path                  = "/"
  force_detach_policies = true
}

resource "aws_iam_instance_profile" "kiam" {
  name_prefix = "${local.cluster_name}_kiam"
  role        = "${aws_iam_role.kiam.id}"

  path = "/"
}

resource "aws_iam_role_policy_attachment" "kiam_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_autoscaling" {
  policy_arn = "${aws_iam_policy.kiam_autoscaling.arn}"
  role       = "${aws_iam_role.kiam.name}"
}

resource "aws_iam_policy" "kiam_autoscaling" {
  name_prefix = "eks-kiam-autoscaling-${local.cluster_name}"
  description = "EKS worker node autoscaling policy for cluster ${local.cluster_name}"
  policy      = "${data.aws_iam_policy_document.worker_autoscaling.json}"
  path        = "/"
}

resource "aws_iam_role_policy" "kiam_server_node" {
  name = "kiam_server_node"
  role = "${aws_iam_role.kiam.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "${aws_iam_role.kiam_server_role.arn}"
    }
    ]
  }
EOF
}

resource "aws_iam_role" "kiam_server_role" {
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
        "AWS": "${aws_iam_role.kiam.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kiam_server_policy" {
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

resource "aws_iam_policy_attachment" "kiam_server_policy" {
  name       = "kiam_server_policy"
  roles      = ["${aws_iam_role.kiam_server_role.name}"]
  policy_arn = "${aws_iam_policy.kiam_server_policy.arn}"
}

########

resource "aws_iam_role" "workers" {
  name_prefix           = "${local.cluster_name}_worker_node"
  assume_role_policy    = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
  permissions_boundary  = ""
  path                  = "/"
  force_detach_policies = true
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${local.cluster_name}_worker_node"
  role        = "${aws_iam_role.workers.id}"

  path = "/"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = "${aws_iam_policy.worker_autoscaling.arn}"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${local.cluster_name}"
  description = "EKS worker node autoscaling policy for cluster ${local.cluster_name}"
  policy      = "${data.aws_iam_policy_document.worker_autoscaling.json}"
  path        = "/"
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${local.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
