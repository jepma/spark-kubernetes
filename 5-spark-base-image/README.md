# Build Spark base image

- Download latest version from https://spark.apache.org/downloads.html

## Build image

- Goto root of the directory
- Build base image containing Spark binaries
- Build python mage

```
docker build -t jepmam/spark-kubernetes -f kubernetes/dockerfiles/spark/Dockerfile .
docker build -t jepmam/spark-kubernetes-python -f kubernetes/dockerfiles/spark/bindings/python/Dockerfile --build-arg base_img="jepmam/spark-kubernetes" .
```

## Build AWS SDK Image

We need to run this from within the current directory (of this README) and run:

```
docker build -t jepmam/spark-kubernetes-python-aws:latest -f Dockerfile-aws-sdk .
```
