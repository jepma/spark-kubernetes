# Kiam

## Cert Manager

To encrypt traffic to- and from KIAM components, certificates needs to be managed. For this cert-manager by Jetstack is used.

> We still need to manually apply the certificates because custom Kubernetes resources are not yet supported by Terraform

```
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.7.2/deploy/manifests/cert-manager.yaml --validate=false
```

> The `--validate=false` is important for kubectl version v1.12 or below.

### CA Issuer Certs

```
pushd certmanager
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f ca-issuer-certs.yaml
popd
```

## Server

The server needs a RBAC setup and service account to function properly. Also, we need a CA to generate a certificate that is used to encrypt traffic between KIAM agent and server.

```
pushd server
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f server-rbac.yaml -f server.yaml
popd
```

## Agent

```
pushd agent
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f agent.yaml
popd
```

> *Important:* Make sure you use the proper ENI for the agent. For EKS `!eth0` should be good enough, as all traffic on other NICS will be intercepted (if they are for the metadata service). The complete list can be found here: https://github.com/uswitch/kiam/tree/master#typical-cni-interface-names

## Install sample application

### IAM Roles + Policies + S3 Bucket

```
pushd demo-app
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- terraform apply
popd
```

### APP

```
pushd demo-app
aws-vault exec --no-session --assume-role-ttl=60m xebia-eks -- kubectl apply -f namespace.yaml -f pod.yaml
popd
```
