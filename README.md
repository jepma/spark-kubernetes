# Spark on Kubernetes

## TODO / Questions

- Get AWS credentials from Kubernetes Secrets Manager
    - Create temporary AWS Credentials per model
- Is it possible to run Spark 2.4.0 on EKS?
- Benchmark performance on EKS vs performance on EMR
- Run Minio on Kubernetes to host testdata
- Host Jupyter on Kubernetes
    - Is it possible to re-use base image
- Is it possible to create a multistage Dockerfile for Spark?

### Workflow

- Use Docker image to run spark script directly (no Kubernetes, but with docker-compose)
    - Add volume to Docker container to access resources
- Local Kubernetes volumes - how does this work

## Versions used

- minikube `v0.31.0`
- Spark `v2.4.0`
- Hadoop `v2.8.5` (also used within EMR now)
- Kubernetes `v1.10.0`

## Sources

- https://github.com/apache/spark
- https://spark.apache.org/docs/2.3.0/running-on-kubernetes.html
- https://kubernetes.io/docs/concepts/storage/storage-classes/
- https://icicimov.github.io/blog/virtualization/Kubernetes-shared-storage-with-S3-backend/

## General notes / takeaways

- Currently Spark on YARN + pyspark does not support driver-mode cluster; which means that the driver is always in between.
- You need to compile Spark 2.4.0 to use `pyspark` with the driver inside the Kubernetes cluster
- To use Python3 with pyspark, set `export PYSPARK_PYTHON=python3`
- You need to compile Spark together with Hadoop libraries - of the samen version that is being used inside your cluster.
    - Hadoop-AWS also need to match a specific version of AWS_JAVA_SDK
    - Version 2.7.3 (widely used within AWS) contains a S3 AnonymousAWSCredentialsProvider bug

## Starting cluster

```
minikube config set memory 8192
minikube config set cpus 4
minikube start
eval $(minikube docker-env)
```

## Create Spark Kubernetes config

### Namespace

```
kubectl create namespace spark-ns
```

```
kubectl create -f kube-conf/spark-namespace.json
```

### Service Account

```
kubectl create serviceaccount spark --namespace=spark-ns
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=spark-ns:spark --namespace=spark-ns
```

## Building Spark

It is important that we build Spark with the proper version of Hadoop. By default this will be version `2.7.3`, as this contains some bugs and is nearly 5 years old already, we want to use a more recent version. Dependencies can be found [here](https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-project/2.8.5)

```
wget https://github.com/apache/spark/archive/v2.4.0.tar.gz
tar -xvf spark-v2.4.0.tar.gz
./build/mvn -Pkubernetes -Dhadoop.version=2.8.5 -Dcurator.version=2.7.1 -DskipTests clean package
./bin/docker-image-tool.sh -m -t latest build
```

> There are some profiles defined for specific hadoop versions, these do not match with our requirement 2.8.5. If you do want to use 3.1 or 2.7, you could use the flag `-Phadoop-2.7`

## Starting PySpark shell

```
./pyspark --master k8s://$(minikube ip):8443 \
    --conf spark.kubernetes.container.image=jepmam/spark-kubernetes-py-base:latest \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.namespace=spark-ns \
    --conf spark.executor.instances=1
```

## Spark-Submit + Python application

```
./spark-submit \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.container.image=spark-application-pi:latest \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.namespace=spark-ns \
  local:///opt/spark/work-dir/main.py
```

## Spark Submit + Python application + S3 (AnonymousAWSCredentialsProvider)

```
./spark-submit \
  --verbose \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.container.image=spark-application-s3:latest \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.AnonymousAWSCredentialsProvider \
  local:///opt/spark/work-dir/main.py
```

## Using secrets

### Create secrets

We can create a secret via a `yaml` file or directly via the CLI. The sample inside `kube-conf/` has `admin` as a value. In the `demo-read-secret` Dockerimage we will read this value from the Secret Volume. As you will notice you do not have to `base64 --decode` this value, Kubernetes will do this for you.

```
kubectl create -f kube-conf/demo-secret.yaml
```

### Attach secret to Spark application

> Source: https://github.com/apache/spark/blob/master/docs/running-on-kubernetes.md

## PySpark shell with secrets

```
./pyspark --master k8s://$(minikube ip):8443 \
    --conf spark.kubernetes.container.image=jepmam/spark-kubernetes-py-base:latest \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.namespace=spark-ns \
    --conf spark.kubernetes.executor.secrets.demosecret=/etc/secrets \
    --conf spark.executor.instances=1
```

### Spark Submit + Python application + S3 (Using Secrets manager)

```
./spark-submit \
  --verbose \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.container.image=spark-application-secret-read:latest \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.driver.secrets.demosecret=/etc/secrets \
  --conf spark.kubernetes.executor.secrets.demosecret=/etc/secrets \
  local:///opt/spark/work-dir/main.py
```

## Spark Submit + Python application + Minio

```
./spark-submit \
  --verbose \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.container.image=spark-application-s3:latest \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.hadoop.fs.s3a.endpoint=http://192.168.205.201:9000 \
  --conf spark.hadoop.fs.s3a.secret.key=minio123 \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  local:///opt/spark/work-dir/main.py
```

## Errors we ran into

### No AWS Credentials provided by BasicAWSCredentialsProvider

> py4j.protocol.Py4JJavaError: An error occurred while calling o683.csv.
: java.io.InterruptedIOException: doesBucketExist on xebiadevops.com: com.amazonaws.AmazonClientException: No AWS Credentials provided by BasicAWSCredentialsProvider EnvironmentVariableCredentialsProvider SharedInstanceProfileCredentialsProvider : com.amazonaws.SdkClientException: Unable to load credentials from service endpoint

## S3 Support

- You can access S3 via the AWS-SDK in combination with AWS credentials.
- Credentials can be provided via Kubernetes Secrets Manager

## Development workflow

- Run Jupyter locally or in the cloud
- Builing docker image with the spark-application inside
- Use generated testdata via Minio (Local S3)

## Performance AWS KMS

- TBD
