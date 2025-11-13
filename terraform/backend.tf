# backend.tf - Configures remote state storage for Terraform

terraform {
  backend "s3" {
    bucket = "cloudnorth-tfstate-ayorinde1982" # Our official S3 bucket name
    key    = "global/eks/terraform.tfstate"
    region = "us-east-1"
  }
}
