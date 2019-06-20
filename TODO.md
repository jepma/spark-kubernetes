## TODO / Questions

- How to give EKS cluster permissions to a group of people?
  Since only roles are supported does this only work when assuming roles? Not when a role has been added to an IAM group?
  See https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
- Get AWS credentials from Kubernetes Secrets Manager
    - Create temporary AWS Credentials per model
    - Try out https://github.com/uswitch/kiam
- Benchmark performance on EKS vs performance on EMR
    - Use public dataset, files > 1gb
    - Test with and without caching
- How is the integration with Glue / Data-catalogs
    - hive-site.xml / glue / spark
- Run Minio on Kubernetes to host testdata
- Host Jupyter on Kubernetes
    - Is it possible to re-use base image
- Is it possible to create a multistage Dockerfile for Spark?
- Create map / workflow -> How does Spark work on Kubernetes
- Best practices -> Kubernetes + Spark
- Calculate costs -> comparison with EMR?
    - HorizontalPodAutoscaler
    - Autoscaler - AWS (NodeAutoscaler -> Kubernetes)
        - Custom Metrics
- Kubernetes Secrets - enable encryption
- How to use Docker image to run spark script directly (no Kubernetes, but with docker-compose)
    - Add volume to Docker container to access resources
- Local Kubernetes volumes - how does this work
