# EKS cluster for running Spark applications

# Prerequisites
- [Terraform](https://github.com/hashicorp/terraform) 0.11.14
- [awscli](https://pypi.org/project/awscli/) >= 1.16.156
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)

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

Run this from the root of this repo

```bash
aws eks --region eu-west-1 update-kubeconfig --name spark-eks --kubeconfig kubeconfig
export KUBECONFIG=$PWD/kubeconfig
# Check if it works
kubectl get nodes
```

# Cert Manager

To encrypt traffic to- and from KIAM components, certificates needs to be managed. For this cert-manager by Jetstack is used.

> We still need to manually apply the certificates because custom Kubernetes resources are not yet supported by Terraform

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.7.2/deploy/manifests/cert-manager.yaml --validate=false
```

> The `--validate=false` is important for kubectl version v1.12 or below.

# Run the Kubernetes Dashboard
To be able to get a graphical overview of what's happening we'll deploy the Kubernetes Dashboard
https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

# Submitting a spark application
```bash
# Create the spark-ns namespace
kubectl create namespace spark-ns
# Create the spark-sa serviceaccount
kubectl create serviceaccount spark-sa --namespace=spark-ns
kubectl create rolebinding spark-rb --clusterrole=edit --serviceaccount=spark-ns:spark-sa --namespace=spark-ns
# Run the kubectl proxy so we can access the kubernetes master endpoint locally without credentials
kubectl proxy
# Submit the spark application
spark-submit \                                       
  --deploy-mode cluster \      
  --master k8s://http://127.0.01:8001 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-pi:latest \
  local:///opt/spark/work-dir/main.py
```

# Adding a worker group

It is important that when you add a worker group, you add the ARN of the instance-profile to the node-config module as well. This will add the ARN to the AWS Auth Config Map.
