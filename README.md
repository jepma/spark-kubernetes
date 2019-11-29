# Spark on Kubernetes

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
- You need to compile Spark together with Hadoop libraries - of the samenversion that is being used inside your cluster.
    - Hadoop-AWS also needs to match a specific version of AWS_JAVA_SDK
    - Version 2.7.3 (widely used within AWS) contains an S3 AnonymousAWSCredentialsProvider bug
- EKS clusters get the user that created the cluster, hardwired in it's configuration.
    - If you want to add other users, update the ConfigMap accordingly
- You will need the `aws-iam-authenticator` to authenticate the tunnel for kubectl.

## Starting cluster

```
minikube config set memory 8192
minikube config set cpus 4
minikube start
eval $(minikube docker-env)
```

## Kubernetes config

### Namespace
We'll use a custom namespace called `spark-ns` for running our Spark applications:
```
# Directly using the command-line
kubectl create namespace spark-ns
# Or using a predefined JSON config
kubectl create -f kube-conf/spark-namespace.json
```

### Service Account
We'll use a custom service account called `spark-sa` which gets permissions to create/manage pods and services within the `spark-ns` namespace.
This service account will be used by the Spark driver pod.
```
# Directly using the command-line
# Add the service account
kubectl create serviceaccount spark-sa --namespace=spark-ns
# Add the "edit" cluster role to the spark-sa service account
kubectl create rolebinding spark-rb --clusterrole=edit --serviceaccount=spark-ns:spark-sa --namespace=spark-ns
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

## PySpark shell

```
docker build -t spark-kubernetes-py-base docker-images/spark-kubernetes-py-base
./pyspark \
    --master k8s://$(minikube ip):8443 \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
    --conf spark.kubernetes.namespace=spark-ns \
    --conf spark.executor.instances=1 \
    --conf spark.kubernetes.container.image=jepmam/spark-kubernetes-py-base:latest
```

## Spark-submit + Python application

```
docker build -t spark-application-pi docker-images/spark-application-pi
./spark-submit \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-pi:latest \
  local:///opt/spark/work-dir/main.py
```

## Spark submit + Python application + S3 (AnonymousAWSCredentialsProvider)

```
docker build -t spark-application-s3 docker-images/spark-application-s3
./spark-submit \
  --deploy-mode cluster \
  --master k8s://$(minikube ip):8443 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa \
  --conf spark.kubernetes.namespace=spark-ns \
  --conf spark.executor.instances=1 \
  --conf spark.kubernetes.container.image=jepmam/spark-application-s3:latest \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.AnonymousAWSCredentialsProvider \
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

> Braindump -> Caching laag middels Minio

### Resources

- https://medium.com/teads-engineering/spark-performance-tuning-from-the-trenches-7cbde521cf60
- https://jaceklaskowski.gitbooks.io/mastering-apache-spark/spark-rdd-caching.html
- https://spark.apache.org/docs/latest/quick-start.html#caching
