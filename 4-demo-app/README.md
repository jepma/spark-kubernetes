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
kubectl apply -f deployments/namespace.yaml -f deployments/pod.yaml
```
