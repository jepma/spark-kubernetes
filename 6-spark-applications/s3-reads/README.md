# Spark Application S3 Reads

The goal of this demo application is to read a lot of files from S3 and process them.

## Build image

```
docker build -t jepmam/spark-applications-s3-reads:latest .
docker push jepmam/spark-applications-s3-reads:latest
```

## Deploy roles

```bash
pushd terraform
terraform init
terraform apply
popd
```

## Deploy application

```bash
pushd deployments
kubectl apply -f namespace.yaml -f serviceaccount.yaml
popd
```

## Run

> Make sure you started the `kubectl proxy` before running this command

```
./spark-submit \
  --deploy-mode cluster \
  --master k8s://http://127.0.0.1:8081 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-application-pi \
  --conf spark.kubernetes.container.image.pullPolicy=Always \
  --conf spark.kubernetes.namespace=spark-applications-pi \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-applications-pi:latest \
  local:///opt/spark/work-dir/main.py
```
