terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "infra-automation/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
