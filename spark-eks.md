# Install aws-iam-authenticator
https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

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

```
$ aws eks --region eu-west-1 update-kubeconfig --name spark-eks --kubeconfig kubeconfig
$ export KUBECONFIG=$PWD/kubeconfig
# Check if it works
$ kubectl get nodes
```

# Run the Kubernetes Dashboard
To be able to get a graphical overview of what's happening we'll deploy the Kubernetes Dashboard
https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

# Submitting a spark application
```
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
