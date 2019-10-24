# EKS cluster for running Spark applications

# Prerequisites
- [Terraform](https://github.com/hashicorp/terraform) 0.11.14
- [awscli](https://pypi.org/project/awscli/) >= 1.16.156
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
- [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) ??

Make sure the access to your AWS account is setup (i.e. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set).

# Create EKS cluster
Apply the Terraform plan in the `eks` directory.
```bash
cd eks
terraform init
terraform apply
```

It uses the [terraform-aws-eks module](https://github.com/terraform-aws-modules/terraform-aws-eks) to create a functioning EKS cluster.

Note: Allowing additional users, roles or accounts can be done via the `aws-auth` configmap.
See https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html for more information.
There are variables for adding these in the terraform-aws-eks module.

# Create kubectl config

```bash
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- aws eks --region eu-west-1 update-kubeconfig --name spark-eks --kubeconfig ../kubeconfig
export KUBECONFIG=$PWD/kubeconfig
# Check if it works
kubectl get nodes
```

# Adding a worker group

It is important that when you add a worker group, you add the ARN of the instance-profile to the node-config module as well. This will add the ARN to the AWS Auth Config Map.
