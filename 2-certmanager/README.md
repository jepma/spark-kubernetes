# Install certmanager for EKS

To encrypt traffic to- and from KIAM components, certificates needs to be managed. For this cert-manager by Jetstack is used.

> We still need to manually apply the certificates because custom Kubernetes resources are not yet supported by Terraform

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f cert-manager-v0.7.2.yaml --validate=false
```

> The `--validate=false` is important for kubectl version v1.12 or below.
