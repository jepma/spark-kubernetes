terraform {
  backend "s3" {
    bucket       = "spark-eks-terraform-state"
    key          = "spark-application-pi.tfstate"
    session_name = "terraform"
    region       = "eu-west-1"
  }
}
