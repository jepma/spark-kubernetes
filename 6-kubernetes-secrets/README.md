TODO


# Using secrets

> By default this is not encrypted!

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

## Create secrets
We can create a secret via a `yaml` file or directly via the CLI. The sample inside `kube-conf/` has `admin` as a value. In the `spark-application-secret-read` Docker image we will read this value from the Secret Volume. As you will notice you do not have to `base64 --decode` this value, Kubernetes will do this for you.

```
kubectl create -f kube-conf/demo-secret.yaml
```

## Attach secret to Spark application
> Source: https://github.com/apache/spark/blob/master/docs/running-on-kubernetes.md

### PySpark shell with secrets

```
./pyspark --master k8s://$(minikube ip):8443 \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
    --conf spark.kubernetes.namespace=spark-ns \
    --conf spark.kubernetes.executor.secrets.demosecret=/etc/secrets \
    --conf spark.executor.instances=1 \
    --conf spark.kubernetes.container.image=jepmam/spark-kubernetes-py-base:latest
```

## Spark Submit + Python application + S3 (Using Secrets manager)

```
docker build -t spark-application-secret-read docker-images/spark-application-secret-read
./spark-submit \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-secret-read:latest \
  --conf spark.kubernetes.driver.secrets.demosecret=/etc/secrets \
  --conf spark.kubernetes.executor.secrets.demosecret=/etc/secrets \
  local:///opt/spark/work-dir/main.py
```

## Spark Submit + Python application + secret env var

```
./spark-submit \
  --verbose \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-secret-read:latest \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.driver.secretKeyRef.My_password=demosecret:accesskey \
  --conf spark.kubernetes.executor.secretKeyRef.My_password=demosecret:accesskey \
  local:///opt/spark/work-dir/main.py
```

## Spark Submit + Python application + Minio

```
./spark-submit \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-s3:latest \
  --conf spark.hadoop.fs.s3a.endpoint=http://192.168.205.201:9000 \
  --conf spark.hadoop.fs.s3a.secret.key=minio123 \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  local:///opt/spark/work-dir/main.py
```
