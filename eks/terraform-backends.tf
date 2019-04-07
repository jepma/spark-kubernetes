terraform {
  backend "s3" {
    region       = "eu-west-1"
    bucket       = "spark-eks-terraform-state"
    key          = "eks.tfstate"
    session_name = "terraform"
  }
}
