
resource "aws_s3_bucket" "bucket" {
  bucket = "eks-demo-app-bucket-randomword-harmony"
  region = "eu-west-1"
  acl    = "private"

  tags {
    name      = "demo-bucket"
    Terraform = "True"
  }
}

resource "aws_s3_bucket_object" "demo" {
  key     = "demo.csv"
  bucket  = "${aws_s3_bucket.bucket.id}"
  content = "foo"
}
