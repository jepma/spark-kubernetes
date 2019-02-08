# Google Cloud Engine

## Environment setup

Cluster name is `spark-on-k8s`

```sh
export PROJECT=$(gcloud info --format='value(config.project)')
export KUBERNETES_CLUSTER_NAME=spark-on-k8s
export KUBERNETES_MASTER_IP=$(gcloud container clusters list --filter name=$KUBERNETES_CLUSTER_NAME --format='value(MASTER_IP)')
```
## Setup properties

```sh
cat > properties << EOF
spark.app.name  spark-on-k8s
spark.kubernetes.namespace=spark-ns
spark.kubernetes.driverEnv.GCS_PROJECT_ID $PROJECT
spark.kubernetes.driverEnv.GOOGLE_APPLICATION_CREDENTIALS /mnt/secrets/spark-sa.json
spark.kubernetes.container.image=jepmam/spark-kubernetes-py-base:latest
spark.kubernetes.driver.secrets.spark-sa  /mnt/secrets
spark.kubernetes.executor.secrets.spark-sa /mnt/secrets
spark.executor.instances=1
spark.executorEnv.GCS_PROJECT_ID    $PROJECT
spark.executorEnv.GOOGLE_APPLICATION_CREDENTIALS /mnt/secrets/spark-sa.json
spark.hadoop.google.cloud.auth.service.account.enable true
spark.hadoop.google.cloud.auth.service.account.json.keyfile /mnt/secrets/spark-sa.json
spark.hadoop.fs.gs.project.id $PROJECT
EOF
```

## PySpark shell

```sh
pyspark \
    --master k8s://https://$KUBERNETES_MASTER_IP:443 \
    --properties-file properties
```

## Resources

* https://cloud.google.com/solutions/spark-on-kubernetes-engine
