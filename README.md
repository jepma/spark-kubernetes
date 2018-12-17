# Spark on Kubernetes


## TODO

- Use Docker image to run spark script directly (no Kubernetes)
- Add volume to Docker container to access resources
- Add AWS libraries to Docker image to access objects on S3
- Run image with AWS libraries on EKS
- Benchmark performance on EKS vs performance on EMR

## Versions used

- minikube `v0.31.0`
- Spark `v2.4.0`
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

## Starting cluster

```
minikube config set memory 8192
minikube config set cpus 4
minikube start
eval(minikube docker-env)
```

## Building Spark

```
wget https://github.com/apache/spark/archive/v2.4.0.tar.gz
tar -xvf spark-v2.4.0.tar.gz
./build/mvn -Pkubernetes -DskipTests clean package
./bin/docker-image-tool.sh -m -t spark-docker build
```

## Starting PySpark shell

```
./pyspark --master k8s://$(minikube ip):8443 --conf spark.kubernetes.container.image=spark-py:spark-docker --conf spark.executor.instances=1
```


## S3 Support

- You can access S3 via the AWS-SDK in combination with AWS credentials.
- Credentials can be provided via Kubernetes Secrets Manager
- **TODO:** Check if it is possible

## Local workflow

- Builing docker image
- Using testdata
-

## Performance AWS KMS

- TBD
