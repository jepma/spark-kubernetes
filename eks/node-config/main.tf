data "aws_eks_cluster" "this" {
  name = "${var.cluster_name}"
}

data "aws_eks_cluster_auth" "this" {
  name = "${data.aws_eks_cluster.this.name}"
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.this.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.this.token}"
  load_config_file       = false
}

locals {
  mapped_role_format = <<MAPPEDROLE
- rolearn: %s
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
MAPPEDROLE
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapAccounts = <<MAPACCOUNTS
MAPACCOUNTS

    mapRoles = "${join("\n", formatlist(local.mapped_role_format, var.worker_role_arn))}"

    mapUsers = <<MAPUSERS
- userarn: arn:aws:iam::${var.account_id}:user/mjepma
  username: mjepma
  groups:
    - system:masters
- userarn: arn:aws:iam::${var.account_id}:user/svanderveldt
  username: svanderveldt
  groups:
    - system:masters
MAPUSERS
  }
}
