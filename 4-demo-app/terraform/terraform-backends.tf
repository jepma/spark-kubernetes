terraform {
  backend "s3" {
    key          = "eks-kiam-demo-app.tfstate"
    session_name = "terraform"
    bucket       = "spark-eks-terraform-state"
    region       = "eu-west-1"
  }
}
