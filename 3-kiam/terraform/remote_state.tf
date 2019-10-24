data "terraform_remote_state" "eks" {
  backend = "s3"

  config {
    region       = "eu-west-1"
    bucket       = "spark-eks-terraform-state"
    key          = "eks.tfstate"
    session_name = "terraform"
  }
}
