# Kiam

## Create IAM roles and policies

```bash
pushd terraform
terraform init
terraform apply
popd
```

### CA Issuer Certs

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f deployments/ca-issuer-certs.yaml
```

## Server

The server needs a RBAC setup and service account to function properly. Also, we need a CA to generate a certificate that is used to encrypt traffic between KIAM agent and server.

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f deployments/server-rbac.yaml -f deployments/server.yaml
```

## Agent

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f deployments/agent.yaml
```

> *Important:* Make sure you use the proper ENI for the agent. For EKS `!eth0` should be good enough, as all traffic on other NICS will be intercepted (if they are for the metadata service). The complete list can be found here: https://github.com/uswitch/kiam/tree/master#typical-cni-interface-names
