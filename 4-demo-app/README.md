# Install sample application

## Create sample application infra

```bash
pushd terraform
terraform init
terraform apply
popd
```

### APP

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f deployments/namespace.yaml -f deployments/pod.yaml
```
