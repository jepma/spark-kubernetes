# aws
variable "region" {}

variable "organization_id" {}
variable "stage" {}
variable "provisioner_role" {}

variable "maintenance_public_key" {
  description = "This holds the public key that will be added to the EC2 configuration"
}
