terraform {
  backend "s3" {
    bucket  = "ifeoma-terraform-iac"
    key     = "terraform.tfstate"
    region  = "us-east-1"
  }
}
