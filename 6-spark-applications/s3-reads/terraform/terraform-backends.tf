terraform {
  backend "s3" {
    bucket       = "spark-eks-terraform-state"
    key          = "spark-applications-s3-reads.tfstate"
    session_name = "terraform"
    region       = "eu-west-1"
  }
}
