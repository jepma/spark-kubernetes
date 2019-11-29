## TODO / Questions

### Main questions

- Calculate costs -> comparison with EMR?
- Benchmark performance on EKS vs performance on EMR
  - Use public dataset, files > 1gb
  - Test with and without caching

### Bonus

- Update user config map: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/355
- How is the integration with Glue / Data-catalogs
  - hive-site.xml / glue / spark
- Host Jupyter on Kubernetes
- Is it possible to create a multistage Dockerfile for Spark?
- Create map / workflow -> How does Spark work on Kubernetes
- Local development
    - Run Minio on Kubernetes (Minikube) to host testdata
    - How to use Docker image to run spark script directly (no Kubernetes, but with docker-compose)
        - Add volume to Docker container to access resources
    - Local Kubernetes volumes - how does this work
