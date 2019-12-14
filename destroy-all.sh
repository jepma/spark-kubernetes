#!/bin/bash

pushd 6-spark-applications/pi/terraform
terraform destroy -auto-approve
popd

pushd 6-spark-applications/s3-reads/terraform
terraform destroy -auto-approve
popd

pushd 6-spark-applications/pi/terraform
terraform destroy -auto-approve
popd

pushd 4-demo-app/terraform
terraform destroy -auto-approve
popd

pushd 3-kiam/terraform
terraform destroy -auto-approve
popd

pushd 1-eks/
terraform destroy -auto-approve
popd

echo "All destroyed"
